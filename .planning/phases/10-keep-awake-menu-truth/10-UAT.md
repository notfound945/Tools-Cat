---
status: complete
phase: 10-keep-awake-menu-truth
source:
  - 10-01-SUMMARY.md
  - 10-02-SUMMARY.md
started: 2026-04-15T01:47:00Z
updated: 2026-04-15T02:01:17Z
---

## Current Test

[testing complete]

## Tests

### 1. Idle menu hides the stop row
expected: Open the live menu while keep-awake is off. You should see the five start rows `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`. You should not see `关闭常亮`, and the idle menu should not add any extra keep-awake status row.
result: pass

### 2. Startup from off keeps the stop row hidden until activation succeeds
expected: Start `无限常亮` or one timed preset from the off state. During the pending transition, `关闭常亮` should still stay hidden and the feedback should appear in the disabled keep-awake status row. After activation succeeds, `关闭常亮` should appear.
result: pass

### 3. Active replacement and stopping keep the stop path truthful
expected: While keep-awake is already active, switching to another preset should keep `关闭常亮` visible during the pending start. When you click `关闭常亮`, the row should remain visible but disabled until the session returns to off.
result: pass

### 4. Countdown and wake-group structure stay compact
expected: In a timed session, countdown text should appear only in the disabled status row, not inside any action title. The root menu should still read keep-awake section -> separator -> wake section -> separator -> quit, without extra visible rows leaking into idle state.
result: pass

## Summary

total: 4
passed: 4
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

none yet
