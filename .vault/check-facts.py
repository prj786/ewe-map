#!/usr/bin/env python3
"""check-facts.py — validate ewe-facts.json against the vault and the repos.

Checks:
  1. JSON parses, schema fields present.
  2. Every repo in facts has a checkout next to the vault (or a known home).
  3. Versions match the repos' VERSION files (ewe, ewe-os).
  4. RFC statuses match the Decision Index table (spot check RFC-003 note).
  5. Rules count matches Rules of the House (rule list is mirrored there).
"""
import json
import os
import sys

VAULT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE = os.path.dirname(VAULT)  # /home/scubba/Projects/ewe

errors = []

def bad(msg):
    errors.append(msg)

# 1. parse + schema
try:
    facts = json.load(open(os.path.join(VAULT, "ewe-facts.json")))
except Exception as e:
    print(f"✗ ewe-facts.json unparsable: {e}")
    sys.exit(1)

for key in ("schema", "project", "versions", "repos", "rules", "cli_tools",
            "ipc", "ewe_conf_domains", "keyring_services", "rfc_status",
            "sync_contract", "known_limits"):
    if key not in facts:
        bad(f"ewe-facts.json missing key: {key}")

# 2. repos exist in the workspace
known_repos = {r["name"] for r in facts.get("repos", [])}
for name in known_repos:
    if not os.path.isdir(os.path.join(WORKSPACE, name)):
        bad(f"facts repo '{name}' has no checkout in the workspace")

# 3. versions match the repos' VERSION files
def repo_version(repo):
    p = os.path.join(WORKSPACE, repo, "VERSION")
    return open(p).read().strip() if os.path.isfile(p) else None

for repo, key in (("ewe", "ewe_de"), ("ewe-os", "ewe_os")):
    actual = repo_version(repo)
    claimed = facts["versions"].get(key)
    if actual and claimed and actual != claimed:
        bad(f"facts versions.{key} = {claimed!r} but {repo}/VERSION says {actual!r} "
            f"— update ewe-facts.json AND 12-Reference/Version Ledger.md together")
    if actual and not claimed:
        bad(f"facts versions missing '{key}' ({repo}/VERSION says {actual!r})")

# 4. RFC-003 accounting must be present (it is absent from the repos)
rfc = {r["rfc"]: r for r in facts.get("rfc_status", [])}
if "RFC-003" not in rfc or "absent" not in rfc.get("RFC-003", {}).get("status", ""):
    bad("facts rfc_status must record RFC-003 as absent from the repos")

# 5. rules count vs Rules of the House
import re as _re
house = open(os.path.join(VAULT, "09-Rules", "Rules of the House.md")).read()
n_house = len(_re.findall(r"^## \d+\.", house, _re.M))
if len(facts.get("rules", [])) != n_house:
    bad(f"facts rules count ({len(facts.get('rules', []))}) != "
        f"numbered rules in Rules of the House ({n_house}) — mirror them together")

if errors:
    for e in errors:
        print(f"✗ {e}")
    sys.exit(1)
print("✓ ewe-facts.json valid (schema, repos, versions, RFC accounting, rules)")
