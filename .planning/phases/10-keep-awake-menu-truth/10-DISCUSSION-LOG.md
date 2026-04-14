# Phase 10: Keep-Awake Menu Truth - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-14T00:00:00Z
**Phase:** 10-keep-awake-menu-truth
**Areas discussed:** idle stop-row visibility, active stop-path behavior, regression anchor

---

## Idle stop-row visibility

| Option | Description | Selected |
|--------|-------------|----------|
| Hide `关闭常亮` when keep-awake is off and no transition is pending | Matches `MENU-01`, keeps the idle root menu truthful, and avoids showing an impossible stop action | ✓ |
| Keep `关闭常亮` visible but disabled in idle state | Preserves fixed row count, but still advertises a meaningless action while idle | |
| Replace `关闭常亮` with a disabled explanatory row | Explains the absence, but adds menu noise and reopens compactness decisions outside this phase | |

**User's choice:** Auto-selected recommended option: hide `关闭常亮` when keep-awake is off and no transition is pending.
**Notes:** Selected automatically to satisfy the milestone goal with the smallest menu change and to preserve the compact idle-menu pattern from earlier phases.

---

## Active stop-path behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Show exactly one `关闭常亮` row only for confirmed active or currently stopping states | Preserves the direct stop path when it is truthful, while avoiding a premature stop action during startup transitions | ✓ |
| Show `关闭常亮` for every pending state, including startup from off | Keeps the row location stable, but advertises stop before a session is actually active | |
| Remove the dedicated stop row and rely on toggling active start rows | Reopens the Phase 4 stop-path decision and weakens manual stop clarity | |

**User's choice:** Auto-selected recommended option: keep one direct stop row only for active and stopping states.
**Notes:** This preserves the Phase 4 direct-stop decision without extending the row into non-actionable startup states.

---

## Regression anchor

| Option | Description | Selected |
|--------|-------------|----------|
| Update the existing keep-awake controller/presentation tests and refresh validation docs | Focused change that locks the new visibility rule without broadening menu scope | ✓ |
| Rely mainly on manual smoke plus a doc note | Lowest effort, but too weak for a truth-contract regression | |
| Expand into a broader root-menu regression rewrite | Stronger coverage, but exceeds the milestone’s narrow scope and adds unrelated churn | |

**User's choice:** Auto-selected recommended option: update the focused existing tests and the phase docs.
**Notes:** Selected automatically because the phase is a small truth fix, not a menu-architecture revisit.

---

## the agent's Discretion

- Exact implementation seam for the visibility helper (`KeepAwakePresentation` versus `StatusBarController`)
- Whether to extend current keep-awake tests or add one narrowly scoped visibility test file
- Exact wording and evidence layout for the updated validation/verification docs

## Deferred Ideas

- Broader keep-awake menu redesign
- New keep-awake presets, shortcuts, or notifications
- Wider verification-strategy changes beyond the focused Phase 10 visibility contract
