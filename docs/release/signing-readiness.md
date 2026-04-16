# Signing Readiness

This document is the canonical maintainer checklist for the Phase 17 signed-DMG release flow. It documents the required release inputs without storing secrets in the repo.

## Prerequisites

Phase 17 expects these Apple command-line tools to be available before `sh ./release.sh` runs:

- `xcodebuild`
- `security`
- `codesign`
- `xcrun`
- `plutil`
- `hdiutil`
- `stapler`
- `spctl`

The public release command stays:

```bash
sh ./release.sh
```

## Certificate bootstrap

The release certificate must be a Developer ID Application identity for Team ID `Y2YJ48R9GL`.

Expected identity label format:

```text
Developer ID Application: <Common Name> (Y2YJ48R9GL)
```

Bootstrap notes:

- Create or download the Developer ID Application certificate from the Apple Developer account for Team `Y2YJ48R9GL`.
- Install the certificate into the login keychain on the maintainer machine that will run the release.
- Confirm the full identity label with `security find-identity -v -p codesigning` before exporting the app.
- Only pass the full label through `RELEASE_SIGNING_IDENTITY`; do not commit certificate names or keychain exports into the repo.

## Notary profile bootstrap

The release preflight requires the named `notarytool` profile that `release.sh` uses for the final DMG notarization step.

Primary setup path:

```bash
xcrun notarytool store-credentials TOOLS_CAT_NOTARY \
  --apple-id "APPLE_ID" \
  --team-id "Y2YJ48R9GL" \
  --password "<app-specific-password>" \
  --validate
```

Rules for this step:

- The app-specific password value must never be stored in the repo, shell scripts, or committed docs beyond the placeholder shown above.
- Keep the secret in Keychain through `notarytool store-credentials`; the repo only stores the profile name `TOOLS_CAT_NOTARY`.
- Re-run the same command with `--validate` if the profile needs to be refreshed on a new machine.

## Phase 17 release runbook

Export the required release inputs and run the canonical release command:

```bash
export RELEASE_TEAM_ID=Y2YJ48R9GL
export RELEASE_SIGNING_IDENTITY='Developer ID Application: <Common Name> (Y2YJ48R9GL)'
export RELEASE_NOTARY_PROFILE=TOOLS_CAT_NOTARY
sh ./release.sh
```

Expected outputs:

- Archive: `build/archive/Tools Cat.xcarchive`
- Exported app: `dist/export/Tools Cat.app`
- Final DMG: `dist/Tools-Cat.dmg`
- Notary submission metadata: `build/notary/Tools-Cat-notary-submit.plist`
- Notary rejection log: `build/notary/Tools-Cat-notary-log.json` (generated when Apple rejects the submission)

Preflight failures you should expect:

- Missing tooling: the script exits before archive work if `xcodebuild`, `security`, `codesign`, `xcrun`, `plutil`, `hdiutil`, `stapler`, or `spctl` is unavailable.
- Missing or wrong identity: the script exits if `RELEASE_SIGNING_IDENTITY` is unset, does not start with `Developer ID Application:`, or is not present in `security find-identity -v -p codesigning`.
- Missing or wrong profile: the script exits if `RELEASE_NOTARY_PROFILE` is unset or `xcrun notarytool history --keychain-profile "$RELEASE_NOTARY_PROFILE"` cannot validate the stored profile.
- Missing Team ID: the script exits if `RELEASE_TEAM_ID` is unset before any long build work starts.

Successful Phase 17 release flow:

1. `release.sh` archives and exports the signed app to `dist/export/Tools Cat.app`.
2. `build_dmg.sh` packages that app into `dist/Tools-Cat.dmg`.
3. `release.sh` signs the final DMG and inspects it with `codesign`.
4. `scripts/release/notarize-dmg.sh` submits the DMG with `xcrun notarytool submit ... --wait --timeout 30m --no-progress -f plist`.
5. If Apple rejects the submission, the script fetches `build/notary/Tools-Cat-notary-log.json` with `xcrun notarytool log` and exits non-zero.
6. If Apple accepts the submission, `release.sh` runs `xcrun stapler staple dist/Tools-Cat.dmg`.
7. `scripts/release/assess-notarized-dmg.sh` validates the stapled DMG with `xcrun stapler validate dist/Tools-Cat.dmg` and `spctl --assess --type open -v dist/Tools-Cat.dmg`.

Phase boundary:

- Phase 17 covers the signed DMG, notarization submission, stapling, and local assessment flow.
- Phase 18 still owns repeatable fresh-machine install verification and the broader release-regression closure.
