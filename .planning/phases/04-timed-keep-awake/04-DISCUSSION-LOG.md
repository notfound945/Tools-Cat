# Phase 4: Timed Keep-Awake - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-12
**Phase:** 04-timed-keep-awake
**Areas discussed:** 菜单结构, 时长预设, 倒计时显示位置, 替换行为, 无限常亮入口, 定时结束后的反馈, 手动关闭入口

---

## 菜单结构

| Option | Description | Selected |
|--------|-------------|----------|
| A | 主菜单保留一个 keep-awake 子菜单，内部再放无限与各个定时项 | |
| B | 主菜单直接展开多行 keep-awake 动作项 | ✓ |
| C | 保留旧主开关，再额外增加一个“定时常亮…”入口 | |

**User's choice:** B
**Notes:** 用户希望 keep-awake 控制直接在主菜单可见，不想通过子菜单再深入一层。

---

## 时长预设

| Option | Description | Selected |
|--------|-------------|----------|
| A | `30 分钟 / 1 小时 / 2 小时` | |
| B | `15 分钟 / 30 分钟 / 1 小时 / 2 小时` | ✓ |
| C | `30 分钟 / 1 小时 / 2 小时 / 4 小时` | |
| D | 其他自定义时长集合 | |

**User's choice:** B
**Notes:** 用户希望预设里包含更短的 15 分钟档位，同时保留 2 小时上限。

---

## 倒计时显示位置

| Option | Description | Selected |
|--------|-------------|----------|
| A | 仅在 keep-awake 状态行显示倒计时 | ✓ |
| B | 直接把倒计时写进动作项标题 | |
| C | 以子菜单状态行展示倒计时 | |

**User's choice:** A
**Notes:** 用户希望动作项标题保持稳定，倒计时通过状态行展示即可。

---

## 替换行为

| Option | Description | Selected |
|--------|-------------|----------|
| A | 当前已有定时会话时，新的定时或无限选择直接替换，不确认 | ✓ |
| B | 仅定时到定时直接替换，切无限走单独流程 | |
| C | 任何替换都先停掉旧会话，再显式开启新会话 | |
| D | 其他自定义规则 | |

**User's choice:** A
**Notes:** 用户希望菜单栏工具保持快速操作，不要增加确认步骤。

---

## 无限常亮入口

| Option | Description | Selected |
|--------|-------------|----------|
| A | 把“无限常亮”与所有定时项并列放在同一组主菜单动作项中 | ✓ |
| B | 保留旧 keep-awake 主项，再额外补几行定时项 | |

**User's choice:** A
**Notes:** 用户希望无限和定时属于同一组能力，不要保留两套分裂入口。

---

## 手动关闭入口

| Option | Description | Selected |
|--------|-------------|----------|
| A | 增加一行明确的 `关闭常亮` | ✓ |
| B | 当前激活的那一行再次点击表示关闭 | |
| C | 仅在会话进行中显示一行 `停止常亮` | |

**User's choice:** A
**Notes:** 用户希望 keep-awake 始终有一个直白、稳定的手动关闭入口，不依赖二义性的再次点击行为。

---

## 定时结束后的反馈

| Option | Description | Selected |
|--------|-------------|----------|
| A | 定时结束后直接回到关闭状态，不保留额外提示 | ✓ |
| B | 回到关闭状态，但短暂显示“定时常亮已结束” | |

**User's choice:** A
**Notes:** 用户偏好更干净的菜单行为，不需要会话结束后的残留提示。

---

## the agent's Discretion

- 倒计时文案的具体格式和精度
- 当前激活项的视觉高亮方式
- timed session 的内部状态模型与计时实现

## Deferred Ideas

None.
