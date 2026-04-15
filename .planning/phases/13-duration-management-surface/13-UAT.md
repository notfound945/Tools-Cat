---
status: diagnosed
phase: 13-duration-management-surface
source:
  - 13-01-SUMMARY.md
  - 13-02-SUMMARY.md
  - 13-03-SUMMARY.md
started: 2026-04-15T17:58:27+08:00
updated: 2026-04-15T18:08:36+08:00
---

## Current Test

[testing complete]

## Tests

### 1. 根菜单中的常亮分组
expected: 打开状态栏菜单后，常亮分组应从上到下显示 `无限常亮`、`15 分钟`、`30 分钟`、`1 小时`、`2 小时`，并在该分组底部看到 `管理常亮时长…`。这项应位于 WOL 分隔线之上，而不是和 WOL 管理项放在同一组。
result: pass

### 2. 打开时长管理窗口
expected: 从状态栏菜单点击 `管理常亮时长…` 后，应打开一个名为 `常亮时长` 的原生窗口。窗口里应直接看到当前受管的定时时长列表，默认至少包含 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`，并有 `添加时长` 按钮；管理列表中不应出现可编辑或可删除的 `无限常亮` 行。
result: issue
reported: "功能正常，但是UI不合我胃口，列表应该有列表的样子，不应该和背景同色，让人不能发现是个列表"
severity: cosmetic

### 3. 添加自定义时长
expected: 在 `常亮时长` 窗口点击 `添加时长` 后，列表应继续保持可见，并在其上方弹出一个小弹窗让你输入分钟数。保存一个当前不存在的新时长后，该时长应立即插入管理列表中的正确排序位置，关闭弹窗后根菜单中的常亮时长列表也应同步立即更新。
result: pass

### 4. 编辑已有时长
expected: 编辑一个已有时长时，应使用和“添加时长”相同的小弹窗，并预填当前分钟值。保存后该行应更新到新的时长值并重排到正确位置；如果改成和现有时长重复，应看到明确的校验提示，而且根菜单中的对应时长也应立即同步刷新。
result: pass

### 5. 删除已有时长
expected: 删除一个已有的定时时长时，应先出现确认；确认后该时长应从管理列表移除，并且根菜单中的对应时长也应立即消失。`无限常亮` 仍应固定为根菜单第一项，且不属于可管理列表。
result: pass

## Summary

total: 5
passed: 4
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "从状态栏菜单点击 `管理常亮时长…` 后，应打开一个名为 `常亮时长` 的原生窗口。窗口里应直接看到当前受管的定时时长列表，默认至少包含 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`，并有 `添加时长` 按钮；管理列表中不应出现可编辑或可删除的 `无限常亮` 行。"
  status: failed
  reason: "User reported: 功能正常，但是UI不合我胃口，列表应该有列表的样子，不应该和背景同色，让人不能发现是个列表"
  severity: cosmetic
  test: 2
  root_cause: "时长列表当前只是裸 `ScrollView` + `LazyVStack`，没有任何独立的列表容器背景、边界、内边距层次或行级表面处理，导致内容直接贴在窗口背景上，视觉上无法被识别成一个可操作列表。"
  artifacts:
    - "Tools Cat/KeepAwakeDurationManagementView.swift:71"
    - "Tools Cat/KeepAwakeDurationManagementView.swift:90"
    - "Tools Cat/KeepAwakeDurationManagementView.swift:230"
    - "Tools Cat/KeepAwakeDurationManagementView.swift:253"
  missing:
    - "缺少一个与窗口背景区分开的原生列表容器样式，例如圆角面板、描边、次级背景色或 inset 分组视觉。"
    - "缺少行级视觉层次，当前各时长项只有文字和分隔线，没有让用户一眼识别为列表项的表面或间距设计。"
  debug_session: "local-diagnosis"
