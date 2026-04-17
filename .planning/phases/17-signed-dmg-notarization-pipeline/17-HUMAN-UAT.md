---
status: superseded
phase: 17-signed-dmg-notarization-pipeline
source: [17-VERIFICATION.md]
started: 2026-04-16T10:25:23Z
updated: 2026-04-17T02:20:00Z
---

## Current Test

Superseded on 2026-04-17 when v1.6 pivoted away from Apple notarization to non-notarized friend sharing.

## Tests

### 1. Real notarized DMG release run
expected: Running `sh ./release.sh` with valid `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE` produces an accepted notarization, staples `dist/Tools-Cat.dmg`, and leaves the final artifact passing both `xcrun stapler validate dist/Tools-Cat.dmg` and `spctl --assess --type open -v dist/Tools-Cat.dmg`.
result: superseded

## Summary

total: 1
passed: 0
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

- Historical only: the pending notarization UAT was canceled by the 2026-04-17 milestone pivot to non-notarized friend sharing.
