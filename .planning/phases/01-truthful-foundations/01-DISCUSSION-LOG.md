# Phase 1: Truthful Foundations - Discussion Log

**Date:** 2026-04-11
**Purpose:** Audit trail of discuss-phase Q&A for human review.
**Outcome:** Decisions captured in `01-CONTEXT.md`

## Selected Discussion Areas

- Manual MAC validation
- Wake result feedback
- Keep-awake toggle semantics
- Window state lifecycle

## Discussion Transcript Summary

### Area: Manual MAC Validation

**Q1:** When should invalid MAC input be blocked?
- Options shown:
  - Real-time validation and disable send while invalid
  - Validate only on send
  - Soft real-time validation with final block on send
  - Other
- User selected: Real-time validation and disable send while invalid

**Q2:** Which manual MAC formats should be accepted?
- Options shown:
  - Accept colon, hyphen, and plain 12-hex
  - Accept colon-delimited only
  - Accept colon-delimited and plain 12-hex
  - Other
- User selected: Accept colon-delimited only

**Q3:** How strict should the field be while typing?
- Options shown:
  - Allow free typing, show format errors in real time, keep send disabled until valid
  - Auto-force colon formatting while typing
  - Allow only hex characters and colon, block other characters immediately, still show real-time errors
  - Other
- User selected: Allow free typing with real-time error display and disabled send until valid

**Q4:** How specific should invalid-input messages be?
- Options shown:
  - One generic error
  - Error messages by type
  - Specific only for empty input, generic otherwise
  - Other
- User selected: Error messages by type

**Continue prompt:** Continue this area or move on?
- User selected: Move on

### Area: Wake Result Feedback

**Q1:** What should success messaging mean?
- Options shown:
  - Explicitly say the wake packet was sent locally from this Mac
  - Keep simple "send succeeded"
  - Show technical destination details
  - Other
- User selected: Explicit local-send wording

**Q2:** How should failure messaging read?
- Options shown:
  - User-friendly reason
  - User-friendly message plus technical detail
  - Raw technical error
  - Other
- User selected: User-friendly reason

**Q3:** What happens to old results when a new send starts?
- Options shown:
  - Clear old result immediately and show only the new result when done
  - Keep old result until replaced
  - Keep old result but label that a new send is in progress
  - Other
- User selected: Clear old result immediately, then show only the new result

**Q4:** Where should result feedback appear?
- Options shown:
  - Existing in-window status region
  - Native alert/sheet
  - In-window status plus extra system notification
  - Other
- User selected: Existing in-window status region

**Continue prompt:** Continue this area or move on?
- User selected: Move on

### Area: Keep-Awake Toggle Semantics

**Q1:** When should menu state and icon change?
- Options shown:
  - Change only after the underlying assertion change succeeds, with transitional feedback first
  - Change immediately on click
  - Keep old state until success/failure without an explicit transitional state
  - Other
- User selected: Change only after success, with transitional feedback first

**Q2:** Where should transitional feedback appear?
- Options shown:
  - In the menu item label, such as "Turning on..." / "Turning off..."
  - Only in the icon
  - In a separate short status message
  - Other
- User selected: In the menu item label

**Q3:** What should happen on keep-awake failure?
- Options shown:
  - Keep the previous confirmed state and show a clear failure message
  - Keep the previous state with no extra message
  - Revert to the previous state after a transitional message and show a short failure reason
  - Other
- User selected: Keep the previous confirmed state and show a clear failure message

**Continue prompt:** Continue this area or move on?
- User selected: Move to the next area

### Area: Window State Lifecycle

**Q1:** Should unfinished input survive close/reopen?
- Options shown:
  - Preserve unfinished input
  - Clear input on every close
  - Preserve only manual input
  - Other
- User selected: Preserve unfinished input

**Q2:** Should previous result text survive reopen?
- Options shown:
  - Clear result text on reopen
  - Preserve result text on reopen
  - Preserve only failure results
  - Other
- User selected: Clear result text on reopen

**Q3:** What happens if the user closes the window while sending?
- Options shown:
  - Continue sending in the background and show final result when reopened
  - Cancel the send on close
  - Do not guarantee final result visibility after close
  - Other
- User selected: Continue sending in the background and show final result when reopened

## Final Direction

- Discussion was sufficient to create phase context.
- User chose to generate the context document rather than explore new gray areas.

## Deferred Ideas

- None raised during the discussion.

