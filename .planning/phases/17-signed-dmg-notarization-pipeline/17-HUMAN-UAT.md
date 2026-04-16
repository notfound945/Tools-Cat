---
status: partial
phase: 17-signed-dmg-notarization-pipeline
source: [17-VERIFICATION.md]
started: 2026-04-16T10:25:23Z
updated: 2026-04-16T10:25:23Z
---

## Current Test

Awaiting credentialed maintainer notarization run.

## Tests

### 1. Real notarized DMG release run
expected: Running `sh ./release.sh` with valid `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE` produces an accepted notarization, staples `dist/Tools-Cat.dmg`, and leaves the final artifact passing both `xcrun stapler validate dist/Tools-Cat.dmg` and `spctl --assess --type open -v dist/Tools-Cat.dmg`.
result: pending

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
