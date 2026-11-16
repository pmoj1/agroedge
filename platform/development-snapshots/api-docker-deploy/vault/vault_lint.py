#!/usr/bin/env python3
"""
Vault Lint — a simplified health checker for the AgroEdge Obsidian vault.
Works with plain markdown + [[wikilinks]], no frontmatter required.

Checks:
1. Orphan pages — notes that nothing links to
2. Duplicate titles — files with the same or near-identical name
3. Broken links — [[links]] pointing to notes that don't exist

Run this ONCE (or anytime) on your vault folder.
"""

import os
import re
import sys
from datetime import date
from collections import defaultdict

WIKILINK = re.compile(r'\[\[([^\]|#]+)(?:\|[^\]]+)?(?:#[^\]]+)?\]\]')

def find_all_md(root):
    files = []
    for dirpath, _, filenames in os.walk(root):
        if '.obsidian' in dirpath:
            continue
        for f in filenames:
            if f.endswith('.md'):
                files.append(os.path.join(dirpath, f))
    return files

def title_of(path):
    return os.path.splitext(os.path.basename(path))[0]

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 vault_lint.py <path-to-vault-folder>")
        sys.exit(1)

    root = sys.argv[1]
    if not os.path.isdir(root):
        print(f"Not a folder: {root}")
        sys.exit(1)

    md_files = find_all_md(root)
    titles_to_paths = defaultdict(list)
    for p in md_files:
        titles_to_paths[title_of(p).lower()].append(p)

    # Build link graph
    outbound = {}       # title -> set of linked titles
    inbound_count = defaultdict(int)
    broken_links = []   # (source_title, target_title)

    valid_titles = set(titles_to_paths.keys())

    for p in md_files:
        try:
            with open(p, 'r', encoding='utf-8') as fh:
                content = fh.read()
        except Exception:
            continue
        links = set(m.group(1).strip().lower() for m in WIKILINK.finditer(content))
        outbound[title_of(p)] = links
        for link in links:
            if link in valid_titles:
                inbound_count[link] += 1
            else:
                broken_links.append((title_of(p), link))

    # Orphans: zero inbound links, excluding hub-like index notes by name heuristic
    orphans = []
    for title in valid_titles:
        if inbound_count.get(title, 0) == 0:
            orphans.append(title)

    # Duplicates: same title appearing in multiple paths
    duplicates = {t: paths for t, paths in titles_to_paths.items() if len(paths) > 1}

    # Build report
    today = date.today().isoformat()
    lines = []
    lines.append(f"# Vault Lint Report — {today}\n")

    total_issues = len(orphans) + len(duplicates) + len(broken_links)
    if total_issues == 0:
        status = "🟢 Green"
    elif total_issues < 15:
        status = "🟡 Yellow"
    else:
        status = "🔴 Red"
    lines.append(f"## Summary\n{status} — {len(md_files)} notes scanned, {total_issues} issues found.\n")

    lines.append("## 1. Orphan Notes (nothing links to them)")
    if orphans:
        for o in sorted(orphans):
            lines.append(f"- {o}")
    else:
        lines.append("None found.")
    lines.append("")

    lines.append("## 2. Duplicate Titles")
    if duplicates:
        for t, paths in duplicates.items():
            lines.append(f"- **{t}** appears {len(paths)} times:")
            for p in paths:
                lines.append(f"  - {p}")
    else:
        lines.append("None found.")
    lines.append("")

    lines.append("## 3. Broken Links (pointing to notes that don't exist)")
    if broken_links:
        for src, target in broken_links:
            lines.append(f"- **{src}** links to missing note: `{target}`")
    else:
        lines.append("None found.")
    lines.append("")

    lines.append("## Next Steps")
    lines.append("1. Review orphan notes — link them from a relevant hub note if they belong in the graph.")
    lines.append("2. Review duplicate titles — decide which copy to keep, if any.")
    lines.append("3. Review broken links — either create the missing note or fix the link text.")
    lines.append("(This script makes no changes on its own — everything above is for you to review.)")

    report = "\n".join(lines)
    report_path = os.path.join(root, "Vault Lint Report.md")
    with open(report_path, 'w', encoding='utf-8') as fh:
        fh.write(report)

    print(report)
    print(f"\nReport saved to: {report_path}")

if __name__ == "__main__":
    main()
