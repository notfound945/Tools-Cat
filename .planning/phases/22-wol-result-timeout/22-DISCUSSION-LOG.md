# Phase 22: WOL Result Timeout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-06
**Phase:** 22-WOL Result Timeout
**Areas discussed:** Result visibility lifetime, consecutive wake behavior, scope guardrails

---

## Result visibility lifetime

| Option | Description | Selected |
|--------|-------------|----------|
| Show indefinitely | Keep the current persistent result until another action clears it | |
| Auto-clear after 3 seconds | Keep the result visible briefly, then remove it automatically in both surfaces | ✓ |
| Use different durations by surface/outcome | Let window/menu or success/failure use different expiry timing | |

**User's choice:** Auto-clear after 3 seconds
**Notes:** User explicitly asked that both the window prompt and the menu-bar prompt disappear after 3 seconds. Scope stays on timing only, not copy changes.

---

## Consecutive wake behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Let old timer continue | A previous result timeout may still fire even after a new send starts | |
| Cancel stale timeout on new send | A new wake action cancels the previous pending clear so only the latest result controls visibility | ✓ |
| Preserve previous result until next completion | Keep the old result visible through the next send and only then restart timing | |

**User's choice:** Cancel stale timeout on new send
**Notes:** This behavior was already captured in roadmap success criteria and aligns with the current in-progress replacement expectation.

---

## Scope guardrails

| Option | Description | Selected |
|--------|-------------|----------|
| Rework WOL copy too | Change result wording while adjusting timeout behavior | |
| Timing-only change | Keep existing copy and wake surface structure, only change result lifetime behavior | ✓ |
| Fold in save-button affordance work | Combine result timeout with saved-device form button gating in the same phase | |

**User's choice:** Timing-only change
**Notes:** User and roadmap both keep `保存设备` enablement for Phase 23 and keep existing wake copy/menu structure unchanged.

---

## the agent's Discretion

- Exact timer abstraction and scheduler/test seam choice.
- Any minimal hidden-window cleanup detail needed so stale results still expire safely without broadening scope.

## Deferred Ideas

- Saved-device `保存设备` button enablement based on required-field completeness remains Phase 23 work.
