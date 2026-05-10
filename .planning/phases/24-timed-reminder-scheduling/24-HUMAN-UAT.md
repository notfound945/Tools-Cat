---
status: partial
phase: 24-timed-reminder-scheduling
source: [24-VERIFICATION.md]
started: 2026-05-10T10:03:00+08:00
updated: 2026-05-10T21:35:51+08:00
---

## Current Test

awaiting remaining human testing

## Tests

### 1. Launch the app from a clean notification-permission state and observe the first authorization prompt
expected: The menu bar item appears immediately, the macOS notification permission prompt appears once, and the app remains responsive while the prompt is shown or answered
result: passed
notes: Passed on 2026-05-10 after the live app showed the startup notification permission prompt as expected.

### 2. Run one timed keep-awake session longer than 2 minutes and one at 2 minutes or less
expected: Only the longer session produces one pre-expiry local notification near endDate minus 120 seconds, and the shorter session produces none
result: pending
notes: Still pending one explicit allowed-notification live run that records both the >2 minute pre-expiry reminder and the <=2 minute skip case.

## Summary

total: 2
passed: 1
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps

- Real allowed-state pre-expiry reminder delivery and short-session skip proof are still pending.
