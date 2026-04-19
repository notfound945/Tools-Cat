# Friend Distribution Readiness

This document is the canonical maintainer checklist for the current non-notarized friend-share DMG flow. The project no longer assumes Apple Developer Program membership, Developer ID, or notarization.

## Prerequisites

This flow expects these command-line tools to be available before `sh ./release.sh` runs:

- `xcodebuild`
- `hdiutil`
- `ditto`

The public release command stays:

```bash
sh ./release.sh
```

## Membership Note

This release path exists specifically for the case where the maintainer does not want to join Apple Developer Program. That means:

- no Developer ID signing chain
- no Apple notarization
- no stapling
- no Gatekeeper-approved double-click install experience

The tradeoff is intentional: the maintainer can still share a DMG with friends, but the friend may need one manual allow step on first launch.

## Release runbook

Run the canonical release command:

```bash
sh ./release.sh
```

Expected outputs:

- Built app: `build/DerivedData/Build/Products/Release/Tools Cat.app`
- Final DMG: `dist/Tools-Cat.dmg`

Preflight failures you should expect:

- Missing tooling: the script exits before build work if `xcodebuild`, `hdiutil`, or `ditto` is unavailable.
- Build failure: the script exits if Xcode cannot produce `build/DerivedData/Build/Products/Release/Tools Cat.app`.

Successful friend-share flow:

1. `release.sh` runs `xcodebuild build` with `CODE_SIGNING_ALLOWED=NO` and `CODE_SIGNING_REQUIRED=NO`.
2. `build_dmg.sh` packages the built app directly into `dist/Tools-Cat.dmg`.
3. The maintainer sends the DMG to a friend together with first-launch instructions.

## Automated verification

After `sh ./release.sh` succeeds, run:

```bash
bash scripts/release/verify-distribution-closure.sh
```

This Phase 18 verification command composes the repo-side checks that should stay repeatable:

1. `scripts/release/verify-release-readiness.sh` confirms the friend-share release contract still matches the current non-notarized DMG flow.
2. `scripts/release/verify-release-docs.sh` confirms `README.md` and this runbook still agree on the release and manual-open story.
3. `scripts/release/verify-friend-share-artifact.sh` mounts `dist/Tools-Cat.dmg` and proves the shipped artifact contains `Tools Cat.app` plus the `/Applications` shortcut.
4. A focused regression slice reruns `Tools CatTests/WOLSessionModelTests`, `Tools CatTests/KeepAwakeSessionModelTests`, `Tools CatTests/KeepAwakeMenuStateTests`, and `scripts/run_menu_bar_verification_slice.sh` so WOL and keep-awake behavior stay unchanged by distribution hardening.

## Friend-side first launch

Because this build is not notarized, friends should expect one of these paths on first launch:

1. Open `Tools-Cat.dmg`.
2. Drag `Tools Cat.app` into `/Applications`.
3. In `/Applications`, launch the app with “右键打开”.
4. If Gatekeeper still blocks launch, remove the quarantine attribute manually:

```bash
xattr -dr com.apple.quarantine "/Applications/Tools Cat.app"
```

## Verification Boundary

- This flow only promises a deterministic Release app and DMG for friend sharing.
- It does not promise notarization, stapling, or Gatekeeper approval.
- Fresh-machine install verification and real friend-side Gatekeeper proof remain manual.
