---
phase: 16
slug: release-signing-readiness
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-16
---

# Phase 16 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest / XCUITest plus shell/grep verification |
| **Config file** | none — Xcode project and shell scripts are the active test/config surface |
| **Quick run command** | `xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' test -quiet` |
| **Full suite command** | `xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' test -quiet` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' test -quiet`
- **After every plan wave:** Run `xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' test -quiet`
- **Before `$gsd-verify-work`:** Full suite must be green, and the release preflight plus archive/export flow must succeed once on a signing-ready machine
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 16-01-01 | 01 | 1 | DIST-01 | shell + static config | `rg -n 'ENABLE_HARDENED_RUNTIME = YES|method</key>|developer-id|signingCertificate|Developer ID Application' "Tools Cat.xcodeproj/project.pbxproj" scripts/release/export-options-developer-id.plist && ! rg -n 'Build/Products/\\$CONFIG|Build/Products/Release|\\*\\.app' release.sh` | ❌ Wave 0 | ⬜ pending |
| 16-01-02 | 01 | 1 | DIST-05 | grep + shell docs check | `rg -n 'Developer ID Application|Team ID|notarytool|store-credentials|preflight' README.md docs/release && ! rg -n 'app-specific password|APPLE_PASSWORD|PRIVATE_KEY|BEGIN PRIVATE KEY' README.md docs/release` | ❌ Wave 0 | ⬜ pending |
| 16-02-01 | 02 | 2 | DIST-01 | manual release smoke | `bash ./release.sh` with valid `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE` on a signing-ready machine | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `scripts/release/export-options-developer-id.plist` — deterministic Developer ID export policy artifact
- [ ] `scripts/release/preflight-signing.sh` or equivalent scripted preflight seam — validates tools, Team ID, identity, and named notary profile before archive
- [ ] Static verification step proving `release.sh` no longer exports from DerivedData pickup and instead uses archive/export
- [ ] Documentation verification step proving README points to a dedicated release doc and that committed docs contain no secret examples

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Exported app is actually Developer ID signed on a credential-ready machine | DIST-01 | The current machine lacks a `Developer ID Application` identity, so real signing cannot be proven in this repo state alone | On a machine with the target Team and certificate installed, run `bash ./release.sh` with the release env inputs set, confirm the export succeeds, then run `codesign -dv --verbose=4 "dist/export/Tools Cat.app" 2>&1 | rg 'Developer ID Application|TeamIdentifier|Runtime Version'` |
| Release docs describe bootstrap without storing secrets in repo | DIST-05 | Secret-safety and operator clarity need a human pass beyond grep | Review `README.md` and `docs/release/signing-readiness.md` together to confirm they describe `notarytool store-credentials`, required env inputs, and preflight usage without embedding credentials |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
