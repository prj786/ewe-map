#!/usr/bin/env python3
"""extract-mermaid.py <outdir> — pull every ```mermaid block out of the vault."""
import os
import re
import sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
outdir = sys.argv[1] if len(sys.argv) > 1 else "/tmp/opencode/mermaid-check"
os.makedirs(outdir, exist_ok=True)
count = 0
for dirpath, dirnames, files in os.walk(root):
    dirnames[:] = [d for d in dirnames if d not in ("attachments", ".quartz", ".git", ".github", "node_modules")]
    for fn in files:
        if not fn.endswith(".md"):
            continue
        p = os.path.join(dirpath, fn)
        text = open(p, encoding="utf-8").read()
        for i, m in enumerate(re.finditer(r"```mermaid\n(.*?)```", text, re.S)):
            rel = os.path.relpath(p, root)
            name = re.sub(r"[^A-Za-z0-9]+", "-", rel)[:-3] + f"-{i}.mmd"
            open(os.path.join(outdir, name), "w", encoding="utf-8").write(m.group(1))
            count += 1
print(f"{count} mermaid blocks extracted to {outdir}")
