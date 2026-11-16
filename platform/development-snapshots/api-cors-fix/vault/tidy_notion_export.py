#!/usr/bin/env python3
"""
Notion export tidy-up pass #2.
1. Deletes duplicate ID-stamped CSVs when a clean-named CSV of the same
   database already exists in the same folder (e.g. keeps "Bug Tracker.csv",
   deletes "Bug Tracker 9e85d99...a_all.csv").
2. Where a folder and a .md file share the same name (Notion's
   folder-for-subpages pattern), leaves both alone but reports them,
   since flattening those safely requires manual review of contents.
Run this ONCE on your vault folder (e.g. "AgroEdge v2").
"""

import os
import re
import sys

CSV_ID_SUFFIX = re.compile(r'\s[0-9a-fA-F]{16,32}_all\.csv$', re.IGNORECASE)
CSV_ID_SUFFIX_SIMPLE = re.compile(r'\s[0-9a-fA-F]{16,32}\.csv$', re.IGNORECASE)

def clean_csv_basename(filename):
    """Return the 'clean' equivalent name for a messy ID-stamped csv."""
    name = CSV_ID_SUFFIX.sub('.csv', filename)
    name = CSV_ID_SUFFIX_SIMPLE.sub('.csv', name)
    return name

def dedupe_csvs(root):
    deleted = []
    for dirpath, _, filenames in os.walk(root):
        csvs = [f for f in filenames if f.lower().endswith('.csv')]
        for f in csvs:
            clean = clean_csv_basename(f)
            if clean != f and clean in filenames:
                # A clean-named duplicate exists — safe to delete the messy one
                messy_path = os.path.join(dirpath, f)
                os.remove(messy_path)
                deleted.append(messy_path)
    return deleted

def find_folder_file_pairs(root):
    pairs = []
    for dirpath, dirnames, filenames in os.walk(root):
        md_names = {os.path.splitext(f)[0] for f in filenames if f.endswith('.md')}
        for d in dirnames:
            if d in md_names:
                pairs.append(os.path.join(dirpath, d))
    return pairs

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 tidy_notion_export.py <path-to-folder>")
        sys.exit(1)

    root = sys.argv[1]
    if not os.path.isdir(root):
        print(f"Not a folder: {root}")
        sys.exit(1)

    print("Step 1: Removing duplicate ID-stamped CSVs...")
    deleted = dedupe_csvs(root)
    for d in deleted:
        print(f"  Deleted duplicate: {d}")
    print(f"Removed {len(deleted)} duplicate CSV files.")

    print("\nStep 2: Checking for folder+file pairs (Notion sub-page pattern)...")
    pairs = find_folder_file_pairs(root)
    print(f"Found {len(pairs)} folder+file pairs. These are left as-is (safe, expected structure):")
    for p in pairs:
        print(f"  {p}  <-->  {p}.md")

    print("\nDone. This is a light cleanup — no notes were deleted, only duplicate CSVs.")

if __name__ == "__main__":
    main()
