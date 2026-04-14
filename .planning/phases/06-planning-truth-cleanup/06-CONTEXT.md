# Phase 6: Planning Truth Cleanup - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Bring the current planning surface back into alignment with the shipped v1.0 scope. This phase updates planning truth in project, verification, and audit-facing docs so they describe the current product and current milestone history accurately. It does not redesign the menu-bar test strategy, add new Wake-on-LAN behavior, or close the remaining Phase 01-04 validation debt.

</domain>

<decisions>
## Implementation Decisions

### Current-truth-first corrections
- **D-01:** Phase 6 should update stale planning files in place so current readers see the current truth first rather than old scope with layered correction notes.
- **D-02:** Historical context may remain only as short explanatory notes where needed to explain why a formerly documented behavior no longer belongs to shipped v1.0.

### Historical note policy
- **D-03:** Removed v1.0 scope such as root-level recent wake rows, old `WOL-04` expectations, and the `所有设备` path should not remain as primary present-tense behavior in current project or verification docs.
- **D-04:** When historical notes are needed, they should be brief and explicitly framed as superseded by the Phase 6 removal / v1.0 archive decision.

### Verification truth model
- **D-05:** Verification documents should describe the current code truth, not preserve obsolete phase-era claims as if they were still active.
- **D-06:** If historical movement matters, explain it through re-verification or narrow historical notes rather than leaving stale frontmatter, stale gaps, or stale requirement claims in place.

### Phase boundary discipline
- **D-07:** Phase 6 is strictly a planning-truth phase. It may touch `PROJECT.md`, relevant `*-VERIFICATION.md` files, and milestone-audit wording where needed to keep those files coherent.
- **D-08:** Phase 6 must not absorb Phase 7 work (menu-bar test-strategy redesign) or Phase 8 work (validation debt cleanup), even if related wording appears nearby.

### the agent's Discretion
- Exact wording, section ordering, and note placement within the touched planning files, as long as current truth is dominant and historical notes remain brief.
- Whether to express superseded behavior through `re_verification`, "Historical note", or similarly narrow explanatory blocks, as long as the file's primary truth becomes current and unambiguous.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and milestone intent
- `.planning/ROADMAP.md` — Defines Phase 6 scope, success criteria, and the hard boundary against Phase 7 and Phase 8 work.
- `.planning/REQUIREMENTS.md` — Defines `DOC-01`, `DOC-02`, and `DOC-03`, which are the acceptance criteria for this cleanup phase.
- `.planning/PROJECT.md` — Defines the current v1.1 hardening goal and states that planning truth must reflect the shipped v1.0 scope.
- `.planning/STATE.md` — Confirms Phase 6 is the active focus and that this milestone is in planning-truth mode rather than feature expansion.

### Prior decisions that constrain the cleanup
- `.planning/phases/03-saved-device-wake-flows/03-CONTEXT.md` — Captures the original Phase 3 menu-recents and `所有设备` decisions that later became historical after the removed Phase 6.
- `.planning/phases/05-native-menu-polish/05-CONTEXT.md` — Captures the later menu-polish decisions that maintained the older root-menu wake model and therefore shape which statements are now stale.

### Files most likely to be corrected in this phase
- `.planning/phases/02-device-library-management/02-VERIFICATION.md` — Still reports `status: gaps_found` for a copy-contract issue that the code later closed.
- `.planning/phases/03-saved-device-wake-flows/03-VERIFICATION.md` — Still describes root-level recents and the `所有设备` path as current v1.0 truth.
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md` — Defines the authoritative post-archive statement that the stale issues are tech debt, not in-scope blockers.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md`: Already contains the corrected post-archive interpretation of the stale Phase 2 and Phase 3 docs.
- `re_verification` structure in `.planning/phases/02-device-library-management/02-VERIFICATION.md`: Can be reused rather than inventing a new historical-correction format.
- Prior phase context files in `.planning/phases/03-saved-device-wake-flows/03-CONTEXT.md` and `.planning/phases/05-native-menu-polish/05-CONTEXT.md`: Provide evidence for how the old wording drift happened.

### Established Patterns
- Planning docs are markdown-first and often preserve history through explicit sections instead of deleting all prior trace.
- Milestone audit files are the canonical place for post-hoc truth when an already-completed phase's original documentation no longer reflects current scope.
- Current maintenance work should stay inside `.planning/` unless a roadmap phase explicitly calls for product-code or test-code changes.

### Integration Points
- Phase 6 will primarily connect `PROJECT.md`, `02-VERIFICATION.md`, `03-VERIFICATION.md`, and `.planning/milestones/v1.0-MILESTONE-AUDIT.md`.
- Any wording in those files that drifts into menu-bar automation strategy must be deferred forward to Phase 7.
- Any wording that implies `wave_0_complete` or validation status changes for Phases 01-04 must be deferred forward to Phase 8 unless needed only to maintain boundary clarity.

</code_context>

<specifics>
## Specific Ideas

- Current truth should be the first thing a maintainer reads; historical context is secondary.
- Short historical notes are acceptable when they explain why a once-valid statement is now out of current scope.
- Verification files should stop acting as frozen historical snapshots when they are being relied on as current maintenance truth.

</specifics>

<deferred>
## Deferred Ideas

- Menu-bar click-path automation wording and real tray-entry coverage decisions belong to Phase 7.
- Phase 01-04 `wave_0_complete` cleanup and validation-file accuracy belong to Phase 8.
- `CONV-04` and any restored recent-device shortcut behavior remain future-scope work outside this phase.

</deferred>

---

*Phase: 06-planning-truth-cleanup*
*Context gathered: 2026-04-13*
