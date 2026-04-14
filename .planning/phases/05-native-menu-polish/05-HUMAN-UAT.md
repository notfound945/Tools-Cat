---
status: passed
phase: 05-native-menu-polish
source: [05-VERIFICATION.md]
started: 2026-04-12T09:08:04Z
updated: 2026-04-12T09:42:55Z
---

## Current Test

final visual approval recorded

## Tests

### 1. Visually confirm the root menu reads keep-awake -> wake -> management in idle and active states
expected: Only native separators divide the three groups, idle hides both status rows, timed keep-awake shows one keep-awake status row, and a wake action shows one truthful wake-status row
result: passed
notes: Approved after final tray polish. The wake group remained compact, `快速WOL` read clearly, `管理 WOL 设备…` stayed in the wake section, and wake-history rows remained absent from the root menu.

### 2. Open the WOL window and review its hierarchy
expected: One heading, one visible input area, optional status block only when meaningful, and one clear primary action in a compact single-column utility window
result: passed
notes: Approved after spacing adjustments. The title no longer crowding the title bar and the bottom action buttons no longer crowding the window edge matched the intended compact native feel.

### 3. Open the device-library window in list, reorder, form, and empty states
expected: List stays primary, reorder mode shows drag affordances without edit/delete mixing, form labels stay above controls with validation directly under fields, and the empty state remains centered and restrained
result: passed
notes: Approved with the saved-device copy refinements. The WOL sender uses `保存设备列表`, the duplicate `已保存设备` heading is gone, and the `快速WOL` submenu presents each saved device as name on the first line with a smaller MAC on the second line.

## Summary

total: 3
passed: 3
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

none
