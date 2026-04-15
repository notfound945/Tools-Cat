---
status: complete
phase: 13-duration-management-surface
source:
  - 13-01-SUMMARY.md
  - 13-02-SUMMARY.md
started: 2026-04-15T08:37:00Z
updated: 2026-04-15T09:09:35Z
---

## Current Test

[testing complete]

## Tests

### 1. 打开时长管理界面
expected: 从状态栏菜单点击 `管理常亮时长…` 后，应打开一个名为 `常亮时长` 的原生窗口。窗口里应直接看到当前受管的定时时长列表，默认至少包含 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`，并且有 `添加时长` 按钮。
result: issue
reported: "管理时长应该在时间栏底部，而不是和WOL功能放一组"
severity: major

### 2. 添加自定义时长
expected: 在 `常亮时长` 窗口点击 `添加时长`，输入一个当前列表里没有的分钟数并保存后，新时长应立即出现在列表中，并按时长从短到长排到正确位置。
result: issue
reported: "添加自定义时长的交互方式我不能接受，不能直接在列表中弹小窗添加吗"
severity: major

### 3. 编辑已有时长
expected: 编辑一个已有时长并保存后，原来的那一行应更新到新的时长值，列表顺序同步刷新到正确位置；如果改成和现有时长重复，应看到明确的校验提示，而不是静默覆盖。
result: issue
reported: "编辑的也需要和添加一个使用一个小弹窗，而不是一个新页面，同时我删除了时长，但菜单中没有实时更新"
severity: major

### 4. 删除已有时长
expected: 删除一个已有的定时时长时，应先出现确认；确认后该时长从管理列表移除。管理界面里不应出现可编辑或可删除的 `无限常亮` 行。
result: pass

## Summary

total: 4
passed: 1
issues: 3
pending: 0
skipped: 0
blocked: 0

## Gaps

- truth: "从状态栏菜单点击 `管理常亮时长…` 后，应打开一个名为 `常亮时长` 的原生窗口。窗口里应直接看到当前受管的定时时长列表，默认至少包含 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`，并且有 `添加时长` 按钮。"
  status: failed
  reason: "User reported: 管理时长应该在时间栏底部，而不是和WOL功能放一组"
  severity: major
  test: 1
  root_cause: "状态栏菜单在初始化时把 `管理常亮时长…` 直接追加在 WOL 分组尾部，未按常亮时长分组就近插入到底部位置。"
  artifacts:
    - "Tools Cat/StatusBarController.swift:130"
    - "Tools Cat/StatusBarController.swift:134"
    - "Tools CatTests/StatusBarControllerMenuPolishTests.swift:24"
    - "Tools CatTests/StatusBarControllerMenuPolishTests.swift:59"
  missing:
    - "缺少针对“管理常亮时长…”位于常亮时长分组底部的菜单顺序约束。"
  debug_session: "local-diagnosis"
- truth: "在 `常亮时长` 窗口点击 `添加时长`，输入一个当前列表里没有的分钟数并保存后，新时长应立即出现在列表中，并按时长从短到长排到正确位置。"
  status: failed
  reason: "User reported: 添加自定义时长的交互方式我不能接受，不能直接在列表中弹小窗添加吗"
  severity: major
  test: 2
  root_cause: "添加流程被建模成 `list/form` 双屏切换，点击添加会把整个管理窗口切到独立表单页，而不是在列表上下文里弹出小窗。"
  artifacts:
    - "Tools Cat/KeepAwakeDurationManagementView.swift:8"
    - "Tools Cat/KeepAwakeDurationManagementView.swift:43"
    - "Tools Cat/KeepAwakeDurationManagementView.swift:134"
    - "Tools Cat/KeepAwakeDurationManagementSessionModel.swift:57"
  missing:
    - "缺少对列表内弹出式添加交互的产品约束和验证。"
  debug_session: "local-diagnosis"
- truth: "编辑一个已有时长并保存后，原来的那一行应更新到新的时长值，列表顺序同步刷新到正确位置；如果改成和现有时长重复，应看到明确的校验提示，而不是静默覆盖。"
  status: failed
  reason: "User reported: 编辑的也需要和添加一个使用一个小弹窗，而不是一个新页面，同时我删除了时长，但菜单中没有实时更新"
  severity: major
  test: 3
  root_cause: "编辑流程同样复用了整页 `form` 模式；同时状态栏控制器只在初始化时创建固定时长菜单项，且没有订阅 `KeepAwakeDurationStore` 的变更，因此删除后管理页更新了本地列表，但状态栏菜单不会实时重建。"
  artifacts:
    - "Tools Cat/KeepAwakeDurationManagementSessionModel.swift:64"
    - "Tools Cat/KeepAwakeDurationManagementSessionModel.swift:116"
    - "Tools Cat/StatusBarController.swift:78"
    - "Tools Cat/StatusBarController.swift:155"
    - "Tools Cat/KeepAwakeDurationStore.swift:10"
  missing:
    - "缺少状态栏菜单与时长仓库联动刷新的观察链路。"
    - "缺少覆盖删除后菜单即时更新的自动化测试。"
  debug_session: "local-diagnosis"
