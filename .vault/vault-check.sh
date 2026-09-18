#!/usr/bin/env bash
# vault-check.sh — verify the ewe project-map vault stays honest.
#
# Checks: wikilink resolution, frontmatter tags, code-fence balance,
# orphan notes, ewe-facts.json validity (against the repos), and — with
# --diagrams — that every Mermaid block renders (mermaid-cli).
#
# Usage:
#   .vault/vault-check.sh                 # fast checks
#   .vault/vault-check.sh --diagrams      # + render every mermaid block
#   .vault/vault-check.sh --render-svg    # + commit-able SVG exports
#
# Exit 0 = vault is honest. Exit 1 = fix the listed problems.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
VAULT_ROOT="$(pwd)"
FAIL=0
note() { printf '\033[1;34m==\033[0m %s\n' "$*"; }
bad()  { printf '\033[1;31m✗\033[0m %s\n' "$*"; FAIL=1; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }

RENDER=0
RENDER_SVG=0
case "${1:-}" in
  --diagrams) RENDER=1 ;;
  --render-svg) RENDER=1; RENDER_SVG=1 ;;
esac

# ---------------------------------------------------------------- wikilinks
note "wikilink resolution"
while IFS= read -r -d '' f; do
  while IFS= read -r link; do
    name="${link#\[\[}"; name="${name%\]\]}"
    # skip anything in an inline-code span (Obsidian does not resolve those)
    if [ -z "$name" ]; then continue; fi
    if ! find . -name "$name.md" | grep -q .; then
      bad "unresolved [[$name]] in $f"
    fi
  done < <(grep -oP '\[\[[^\]|]+\]\]' "$f" | sort -u)
done < <(find . -name '*.md' -not -path './quartz-config/*' -not -path './.quartz/*' -print0)
[ "$FAIL" -eq 0 ] && ok "all links resolve"

# -------------------------------------------------------------------- tags
note "frontmatter tags"
while IFS= read -r -d '' f; do
  case "$f" in ./README.md|./Home.md|./quartz-config/*) continue;; esac
  if ! sed -n '1,10p' "$f" | grep -q 'ewe-map'; then
    bad "missing 'ewe-map' tag: $f"
  fi
done < <(find . -name '*.md' -print0)
[ "$FAIL" -eq 0 ] && ok "all notes carry the ewe-map tag"

# ------------------------------------------------------------------ fences
note "code-fence balance"
while IFS= read -r -d '' f; do
  n=$(grep -c '^```' "$f" || true)
  if [ $((n % 2)) -ne 0 ]; then bad "unbalanced fences ($n) in $f"; fi
done < <(find . -name '*.md' -print0)
[ "$FAIL" -eq 0 ] && ok "all fences balanced"

# ----------------------------------------------------------------- orphans
note "orphan notes (nothing links to them)"
while IFS= read -r -d '' f; do
  base=$(basename "$f" .md)
  [ "$base" = "Home" ] || [ "$base" = "README" ] && continue
  n=$(grep -rl --include='*.md' "\[\[$base\]\]" . 2>/dev/null | grep -v -F "$f" | wc -l)
  if [ "$n" -eq 0 ]; then bad "orphan note: $f"; fi
done < <(find . -name '*.md' -not -path './quartz-config/*' -not -path './.quartz/*' -print0)
[ "$FAIL" -eq 0 ] && ok "no orphans"

# ------------------------------------------------------------- facts.json
note "ewe-facts.json"
if [ ! -f ewe-facts.json ]; then
  bad "ewe-facts.json missing"
else
  python3 .vault/check-facts.py || bad "ewe-facts.json failed validation"
fi
[ "$FAIL" -eq 0 ] && ok "facts valid"

# ------------------------------------------------------------- mermaid
if [ "$RENDER" -eq 1 ]; then
  note "mermaid render (mermaid-cli)"
  command -v node >/dev/null || bad "node not found"
  if [ "$FAIL" -eq 0 ]; then
    rm -rf /tmp/opencode/mermaid-check && mkdir -p /tmp/opencode/mermaid-check
    python3 .vault/extract-mermaid.py /tmp/opencode/mermaid-check || bad "extract failed"
    printf '{"args": ["--no-sandbox", "--disable-setuid-sandbox"]}\n' > /tmp/opencode/mermaid-check/puppeteer.json
    for f in /tmp/opencode/mermaid-check/*.mmd; do
      [ -e "$f" ] || continue
      name=$(basename "$f" .mmd)
      if timeout 60 npx -y @mermaid-js/mermaid-cli -i "$f" -o "$f.svg" -p /tmp/opencode/mermaid-check/puppeteer.json >/dev/null 2>"$f.err"; then
        :
      else
        bad "diagram failed to render: $name ($(head -2 "$f.err" | tr '\n' ' '))"
      fi
    done
    [ "$FAIL" -eq 0 ] && ok "all mermaid blocks render"
    if [ "$RENDER_SVG" -eq 1 ] && [ "$FAIL" -eq 0 ]; then
      mkdir -p attachments/diagrams
      cp /tmp/opencode/mermaid-check/*.svg attachments/diagrams/ 2>/dev/null
      ok "SVG exports written to attachments/diagrams/"
    fi
  fi
else
  note "mermaid render skipped (use --diagrams or --render-svg)"
fi

# ---------------------------------------------------------------- result
if [ "$FAIL" -eq 0 ]; then
  printf '\n\033[1;32mVAULT HONEST ✓\033[0m\n'
else
  printf '\n\033[1;31mVAULT DRIFTED — fix the ✗ items above, then re-run.\033[0m\n'
  exit 1
fi
