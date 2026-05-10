---
status: resolved
phase: 25-expiry-reminder-truth
source: [25-VERIFICATION.md]
started: 2026-05-10T03:48:45Z
updated: 2026-05-10T04:08:00Z
---

## Current Test

approved

## Tests

### 1. Real timed expiry end reminder
expected: With notifications allowed, one `常亮已结束` reminder arrives only after the timed session has actually turned off.
result: passed

### 2. Denied-permission timed sessions
expected: With notifications denied, both >2 minute and 2 minute timed sessions still start, count down, and end, while the keep-awake status row shows countdown first and `提醒不可用：通知权限未开启` second.
result: passed

### 3. Foreground reminder presentation
expected: While the app is active/frontmost near expiry, the end reminder still presents through the native Apple notification surface.
result: passed

## Summary

total: 3
passed: 3
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
