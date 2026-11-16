#!/usr/bin/env python3
"""
Notion -> Obsidian cleanup script.
1. Strips the trailing Notion page-ID from filenames and folder names.
2. Converts Notion's markdown links [Title](Title%20abc123.md) into Obsidian [[wikilinks]].
Run this ONCE on your imported Notion export folder.
"""

import os
import re
import sys
import urllib.parse

# The Notion ID pattern: a space followed by 32 hex characters (possibly with dashes)
ID_PATTERN = re.compile(r'\s?[0-9a-fA-F]{32}$')
ID_PATTERN_MD = re.compile(r'\s?[0-9a-fA-F]{32}(?=\.md$)')

def clean_name(name):
    """Remove trailing Notion ID from a filename or folder name (keeps extension)."""
    base, ext = os.path.splitext(name)
    base = ID_PATTERN.sub('', base)
    return base.strip() + ext

def build_rename_map(root):
    """Walk the tree, rename files/folders, return old-name -> new-clean-title map."""
    rename_map = {}

    # Rename deepest first so parent renames don't break child paths
    all_paths = []
    for dirpath, dirnames, filenames in os.walk(root):
        for f in filenames:
            all_paths.append(os.path.join(dirpath, f))
        for d in dirnames:
            all_paths.append(os.path.join(dirpath, d))

    all_paths.sort(key=lambda p: p.count(os.sep), reverse=True)

    for path in all_paths:
        if not os.path.exists(path):
            continue
        parent = os.path.dirname(path)
        old_name = os.path.basename(path)
        new_name = clean_name(old_name)
        if new_name != old_name:
            new_path = os.path.join(parent, new_name)
            counter = 1
            final_path = new_path
            while os.path.exists(final_path) and final_path != path:
                base, ext = os.path.splitext(new_path)
                final_path = f"{base} ({counter}){ext}"
                counter += 1
            os.rename(path, final_path)
            title_no_ext = os.path.splitext(new_name)[0]
            rename_map[old_name] = title_no_ext
    return rename_map

def convert_links(root):
    """Convert [Text](path%20ID.md) style Notion links into [[Text]] wikilinks."""
    link_pattern = re.compile(r'\[([^\]]+)\]\(([^)]+\.md)\)')

    for dirpath, _, filenames in os.walk(root):
        for f in filenames:
            if not f.endswith('.md'):
                continue
            filepath = os.path.join(dirpath, f)
            try:
                with open(filepath, 'r', encoding='utf-8') as fh:
                    content = fh.read()
            except Exception as e:
                print(f"Skipped (read error): {filepath} — {e}")
                continue

            def replacer(match):
                text = match.group(1)
                target = urllib.parse.unquote(match.group(2))
                target_name = os.path.basename(target)
                title = clean_name(target_name)
                title = os.path.splitext(title)[0]
                return f'[[{title}|{text}]]'

            new_content = link_pattern.sub(replacer, content)

            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as fh:
                    fh.write(new_content)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 clean_notion_export.py <path-to-folder>")
        sys.exit(1)

    root = sys.argv[1]
    if not os.path.isdir(root):
        print(f"Not a folder: {root}")
        sys.exit(1)

    print("Step 1: Cleaning filenames...")
    rename_map = build_rename_map(root)
    print(f"Renamed {len(rename_map)} files/folders.")

    print("Step 2: Converting links to [[wikilinks]]...")
    convert_links(root)
    print("Done. Re-open Obsidian and check the Graph view.")

if __name__ == "__main__":
    main()
