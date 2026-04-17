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
- Shared app copy: `dist/Tools Cat.app`
- Final DMG: `dist/Tools-Cat.dmg`

Preflight failures you should expect:

- Missing tooling: the script exits before build work if `xcodebuild`, `hdiutil`, or `ditto` is unavailable.
- Build failure: the script exits if Xcode cannot produce `build/DerivedData/Build/Products/Release/Tools Cat.app`.

Successful friend-share flow:

1. `release.sh` runs `xcodebuild build` with `CODE_SIGNING_ALLOWED=NO` and `CODE_SIGNING_REQUIRED=NO`.
2. The built app is copied to `dist/Tools Cat.app`.
3. `build_dmg.sh` packages that app into `dist/Tools-Cat.dmg`.
4. The maintainer sends the DMG to a friend together with first-launch instructions.

## Friend-side first launch

Because this build is not notarized, friends should expect one of these paths on first launch:

1. Preferred: drag the app into `/Applications`, then use “右键打开”.
2. If Gatekeeper still blocks launch, remove the quarantine attribute manually:

```bash
xattr -dr com.apple.quarantine "/Applications/Tools Cat.app"
```

## Verification Boundary

- This flow only promises a deterministic Release app and DMG for friend sharing.
- It does not promise notarization, stapling, or Gatekeeper approval.
- Fresh-machine install verification still belongs in the follow-up distribution-validation work.
