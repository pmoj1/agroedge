#!/usr/bin/env bash
# AgroEdge — one-time GitHub setup.
# Run this AFTER you have created the AgroEdge organisation at
# https://github.com/organizations/plan (choose Free).
#
# Requires the GitHub CLI: brew install gh

set -euo pipefail

ORG="AgroEdge"
REPO="agroedge-platform"
COLLABORATOR="AONE_GITHUB_USERNAME"   # <-- replace before running

echo "==> Authenticating with GitHub"
gh auth status || gh auth login

echo "==> Creating private repo ${ORG}/${REPO}"
gh repo create "${ORG}/${REPO}" --private --source=. --remote=origin --push

echo "==> Adding Aone as a maintainer"
gh api -X PUT "orgs/${ORG}/memberships/${COLLABORATOR}" -f role=member || true
gh api -X PUT "repos/${ORG}/${REPO}/collaborators/${COLLABORATOR}" -f permission=maintain

echo "==> Protecting main"
gh api -X PUT "repos/${ORG}/${REPO}/branches/main/protection" \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Secret scan"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

echo "==> Enabling secret scanning and push protection"
gh api -X PATCH "repos/${ORG}/${REPO}" \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled' || \
  echo "    (skipped — may require a paid plan on private repos)"

echo
echo "Done. Next:"
echo "  1. cp .env.example .env  and fill it from the shared vault"
echo "  2. Add the same secrets under Settings > Secrets and variables > Actions"
echo "  3. Week 0: A1 runs solo on the schema + OpenAPI contract. Nobody else starts."
