---
status: resolved
phase: 03-saved-device-wake-flows
source: [03-VERIFICATION.md]
started: 2026-04-12T03:32:00Z
updated: 2026-04-12T04:23:37Z
---

## Current Test

Approved the native menu-bar and retained-window GUI validation for the saved-device wake flows.

## Tests

### 1. Compact Wake Menu
expected: Only up to three recent rows appear at the root level, and the full library remains under `所有设备`.
result: approved

### 2. In-Flight Wake Disable State
expected: Recent rows and `所有设备` submenu rows disable while sending, then re-enable after completion.
result: approved

### 3. Reopen Defaults vs Manual Draft Ownership
expected: After a saved-device wake, reopening preselects the last-used device; after entering a partial manual MAC, reopening keeps the draft instead of forcing preset mode.
result: approved

## Summary

total: 3
passed: 3
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

None.
