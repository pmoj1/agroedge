## What changed

<!-- One paragraph. What and why, not how. -->

## Lane

<!-- Which directory do you own for this change? Confirm you touched nothing else. -->

- [ ] This PR only modifies files inside my assigned lane
- [ ] If it touches `packages/shared`, that was the explicit purpose of this PR

## Checks

- [ ] Tests added or updated
- [ ] `flutter analyze` / `tsc --noEmit` passes clean
- [ ] No secrets, keys, or tokens in the diff
- [ ] No PII is logged, and no PII is sent to the Claude API
- [ ] If `db/` changed: RLS enabled on any new farmer-data table, `up` and `down`
      migrations both present, and an unauthorised-read test exists
- [ ] No user-facing string or comment overclaims current company state
      (no signed government contracts, no live production, no executed LOIs)

## Reviewer notes

<!-- Anything the other founder should look at closely. -->
