#!/bin/bash
# Double-click to commit Antigravity's design-system work, merge into main, and push.
set -e
cd "$(dirname "$0")"

echo "==> Repo: $(pwd)"

# Clear any stale git lock
rm -f .git/index.lock

# Ensure a commit identity exists
git config user.name  >/dev/null 2>&1 || git config user.name  "AgroEdge"
git config user.email >/dev/null 2>&1 || git config user.email "agroedgeoff@gmail.com"

# Make sure we're on the feature branch
git checkout antigravity-ui-work

echo "==> Staging and committing uncommitted design-system pass"
git add -A
if git diff --cached --quiet; then
  echo "    Nothing new to commit."
else
  git commit -m "feat: extract reusable design system, migrate screens off custom_components"
fi

echo "==> Merging antigravity-ui-work into main"
git checkout main
git merge --no-ff antigravity-ui-work -m "Merge antigravity-ui-work: UI redesign + design system"

echo "==> Pushing main to origin"
git push origin main

echo ""
echo "==> Done. main is merged and pushed."
echo "Press any key to close."
read -n 1 -s
