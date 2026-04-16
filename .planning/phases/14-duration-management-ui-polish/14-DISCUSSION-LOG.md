# Phase 14: Duration Management UI Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-16
**Phase:** 14-duration-management-ui-polish
**Areas discussed:** list presentation semantics, row action semantics, regression boundary

---

## List presentation semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Native list/table | Use built-in macOS list semantics instead of the custom stacked scroll surface | ✓ |
| Keep grouped custom stack | Preserve the Phase 13 grouped panel and only tweak spacing or borders | |
| Heavier custom chrome | Add stronger bespoke surfaces or ornament to force list readability | |

**User's choice:** `[auto]` Native list/table
**Notes:** Auto-selected from the Phase 14 roadmap and project goals. The milestone explicitly prefers built-in macOS list/table presentation over a lightly skinned custom stack.

---

## Row action semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Semantic tinting | Edit uses app accent/theme color, delete uses destructive red semantics | ✓ |
| Label-only distinction | Keep both actions neutral and rely on text labels alone | |
| Icon-first styling | Lean on icons or custom badges more than semantic color | |

**User's choice:** `[auto]` Semantic tinting
**Notes:** Auto-selected from `AWAKE-15` and the v1.4 roadmap, which explicitly call for accent-colored edit affordances and destructive red delete affordances.

---

## Regression boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Visual polish only | Preserve shipped CRUD, sorting, list-local sheet flow, and live root-menu sync | ✓ |
| Revisit behavior while polishing | Allow the phase to reopen duration-manager or root-menu behavior | |
| Broader manager redesign | Expand scope into a larger duration-management UI rethink | |

**User's choice:** `[auto]` Visual polish only
**Notes:** Auto-selected from the roadmap, requirements, and prior milestone summaries. Phase 14 is intentionally narrow and must not reopen the Phase 13 behavior contract.

---

## the agent's Discretion

- Exact native list implementation choice
- Exact tint application for edit/delete controls
- Row density, spacing, and separator details

## Deferred Ideas

None.
