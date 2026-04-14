# Phase 6: Planning Truth Cleanup - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-13
**Phase:** 06-planning-truth-cleanup
**Areas discussed:** 文档修正策略, 历史记录保留粒度, verification 文件原则, Phase 6 边界

---

## 文档修正策略

| Option | Description | Selected |
|--------|-------------|----------|
| a | 就地改成当前真相，只在必要处保留简短历史说明 | ✓ |
| b | 尽量保留原文，在各处加“后续已变更”的注释 | |
| c | 只改 frontmatter / 结论，不大改正文 | |

**User's choice:** `a`
**Notes:** Current readers should see current truth first. Historical context is allowed only when needed to explain why prior wording no longer applies.

---

## 历史记录保留粒度

| Option | Description | Selected |
|--------|-------------|----------|
| a | 从当前 phase 文档里完全移除旧 `WOL-04` / `所有设备` / root-level recents 叙述 | |
| b | 当前真相为主，但保留一个简短 historical note 说明它们为何不再属于 v1.0 | ✓ |
| c | 不在 phase 文档保留历史，只在 milestone audit / milestone archive 里保留 | |

**User's choice:** `b`
**Notes:** Historical notes should stay brief and subordinate to the current-truth reading of the file.

---

## Verification 文件原则

| Option | Description | Selected |
|--------|-------------|----------|
| a | verification 以“当前代码真相”为准，必要时用 re-verification 区块解释历史变化 | ✓ |
| b | verification 保留“phase 当时真相”，另加一段 current note | |
| c | 不重写正文，只改 status 和 gap summary | |

**User's choice:** `a`
**Notes:** Re-verification style updates are preferred over freezing stale historical claims in active maintenance documents.

---

## Phase 6 边界

| Option | Description | Selected |
|--------|-------------|----------|
| a | 严格只修 planning truth：`PROJECT.md`、相关 `VERIFICATION.md`、必要的 milestone audit wording | ✓ |
| b | 允许顺手修少量 Phase 7 风格的测试说明，只要不改代码或测试 | |
| c | 能修多少修多少，Phase 6 不严格设边界 | |

**User's choice:** `a`
**Notes:** Menu-bar test strategy remains Phase 7 work; validation debt remains Phase 8 work.

---

## the agent's Discretion

- Exact wording and note placement inside the touched planning files
- Whether superseded behavior is explained via `re_verification` or a brief historical-note block

## Deferred Ideas

- Menu-bar click-path verification strategy and automation clarity belong to Phase 7
- Phase 01-04 validation cleanup belongs to Phase 8
- `CONV-04` remains future product scope rather than planning-truth scope
