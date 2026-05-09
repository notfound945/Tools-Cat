# Pitfalls Research

**Domain:** Timed keep-awake reminder pitfalls for `Tools Cat`
**Researched:** 2026-05-09
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Scheduling reminders from UI taps instead of active session truth

**What goes wrong:**
Notifications reflect the user’s initial menu click rather than the session that actually survived replacements, failures, or explicit stops.

**Why it happens:**
It is tempting to schedule local notifications right where the menu action fires.

**How to avoid:**
Schedule and cancel reminders only from `KeepAwakeSessionModel` transitions after the model knows which timed session is currently authoritative.

**Warning signs:**
- Replacing a timed session still delivers the first session’s reminder
- Tests can only prove menu-click behavior, not session-truth behavior

**Phase to address:**
Phase 24

---

### Pitfall 2: Sending misleading “2 分钟前” reminders for short sessions

**What goes wrong:**
A timed session of one or two minutes emits an immediate “about to end” reminder that feels broken or late.

**Why it happens:**
The implementation blindly subtracts two minutes from `endDate` without checking whether enough time remains.

**How to avoid:**
Gate pre-expiry scheduling on remaining duration strictly greater than two minutes and let short sessions keep only the expiry reminder.

**Warning signs:**
- Very short sessions schedule a pre-expiry request at or before “now”
- The reminder logic does not branch on duration length

**Phase to address:**
Phase 24

---

### Pitfall 3: Silent permission failure

**What goes wrong:**
Timed keep-awake works, but reminders never arrive and the user has no idea the feature is unavailable.

**Why it happens:**
Local-notification authorization is easy to treat as best-effort background work.

**How to avoid:**
Keep permission denial or scheduling failure visible through the shared keep-awake presentation while leaving the core timed session behavior intact.

**Warning signs:**
- No new user-visible state appears when notification permission is denied
- The milestone relies on “system settings will handle it” instead of explicit app truth

**Phase to address:**
Phase 25

---

### Pitfall 4: End reminder firing for sessions that never actually ended naturally

**What goes wrong:**
The app sends an “ended” reminder after the user already stopped the session manually or changed to `无限常亮`.

**Why it happens:**
Expiry notifications were scheduled once and never canceled when the session lifecycle changed.

**How to avoid:**
Pair expiry scheduling with explicit cancellation on every stop, replacement, and mode-switch path.

**Warning signs:**
- Stopping a timed session leaves pending notification identifiers around
- Cancellation logic exists only for pre-expiry reminders, not expiry reminders

**Phase to address:**
Phase 25

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding notification API calls directly into `KeepAwakeSessionModel` | Faster first implementation | Makes model tests brittle and couples business truth to system APIs | Never for this repo’s current testing style |
| Treating permission denial as “no-op” | Less UI/presentation work | Violates the project’s visible-truth rule and creates support ambiguity | Never |
| Using one generic notification identifier forever | Simpler scheduling code | Makes stale-notification cancellation unreliable after session replacement | Never |

## "Looks Done But Isn't" Checklist

- [ ] **Pre-expiry reminders:** Verify short timed sessions do not schedule a misleading `2 分钟前` notification
- [ ] **Session replacement:** Verify replacing one timed duration cancels the older session’s pending reminders
- [ ] **Manual stop:** Verify stopping timed keep-awake early cancels both pending reminder requests
- [ ] **Permission denial:** Verify keep-awake still functions and the app surfaces reminder-unavailable truth

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| UI-driven instead of session-driven scheduling | Phase 24 | Model tests prove reminders follow the active confirmed timed session only |
| Misleading short-session pre-reminders | Phase 24 | Tests prove sessions of `<= 2 分钟` skip the pre-expiry request |
| Silent permission failure | Phase 25 | Presentation/menu tests prove reminder-unavailable state is visible |
| Expiry reminder after manual stop or replacement | Phase 25 | Tests prove cancellation clears pending end reminders on all lifecycle exits |

## Sources

- Local repo behavior and current keep-awake architecture
- User-requested milestone scope for v1.9

---
*Pitfalls research for: v1.9 Timed Keep-Awake Notifications*
