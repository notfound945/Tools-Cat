---
status: partial
phase: 22-wol-result-timeout
source: [22-VERIFICATION.md]
started: 2026-05-06T07:32:18Z
updated: 2026-05-06T07:32:18Z
---

## Current Test

Awaiting human verification for live WOL result dwell timing in the window and menu-bar surfaces.

## Tests

### 1. WOL window result dwell
expected: After sending WOL from the window, the success or failure message remains visible for about 3 seconds, then disappears without closing or reopening the window.
result: pending

### 2. Menu-bar wake status dwell
expected: After triggering WOL from the menu, the wake status row shows the sending/result message and then hides itself after about 3 seconds without manual menu cleanup.
result: pending

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps

None yet — waiting on live human verification results.
