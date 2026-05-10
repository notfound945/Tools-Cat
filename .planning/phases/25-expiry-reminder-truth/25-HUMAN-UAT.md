---
status: partial
phase: 25-expiry-reminder-truth
source: [25-VERIFICATION.md]
started: 2026-05-10T03:48:45Z
updated: 2026-05-10T03:48:45Z
---

## Current Test

awaiting human testing

## Tests

### 1. Real timed expiry end reminder
expected: With notifications allowed, one `常亮已结束` reminder arrives only after the timed session has actually turned off.
result: pending

### 2. Denied-permission timed sessions
expected: With notifications denied, both >2 minute and 2 minute timed sessions still start, count down, and end, while the keep-awake status row shows countdown first and `提醒不可用：通知权限未开启` second.
result: pending

### 3. Foreground reminder presentation
expected: While the app is active/frontmost near expiry, the end reminder still presents through the native Apple notification surface.
result: pending

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
