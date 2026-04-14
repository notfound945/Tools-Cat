---
status: resolved
phase: 04-timed-keep-awake
source: [04-VERIFICATION.md]
started: 2026-04-12T07:05:00Z
updated: 2026-04-12T07:14:31Z
---

## Current Test

Approved the native menu-bar smoke for timed keep-awake on the live app.

## Tests

### 1. Fixed keep-awake root menu order and explicit manual-off row
expected: The keep-awake section appears before `发送 WOL …` in the exact order `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`, `关闭常亮`, then one disabled status row.
result: approved

### 2. Infinite mode, timed replacement, and countdown confinement
expected: `无限常亮` checks only itself, switching to `15 分钟` then `30 分钟` replaces immediately without confirmation, and countdown text appears only in the disabled status row.
result: approved

### 3. Manual stop and natural expiry return cleanly to off
expected: `关闭常亮` stays visible at all times, manual stop returns the icon and menu to off, and natural expiry returns directly to the off presentation with no `已结束` banner.
result: approved

## Summary

total: 3
passed: 3
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
