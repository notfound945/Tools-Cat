# External Integrations

**Analysis Date:** 2026-04-11

## APIs & External Services

**Local Network Protocols:**
- Wake-on-LAN over UDP broadcast - The app sends WOL magic packets to LAN broadcast addresses for a selected MAC address from `Tools Cat/WOLSender.swift`.
  - SDK/Client: No third-party SDK; direct POSIX socket calls from `import Darwin` in `Tools Cat/WOLSender.swift`
  - Auth: None
  - Endpoints used: UDP port `9` broadcast targets derived from local IPv4 interfaces in `Tools Cat/WOLSender.swift`

**macOS System Services:**
- IOKit Power Management - The keep-awake feature prevents display sleep through `IOPMAssertionCreateWithName` and releases the assertion on shutdown in `Tools Cat/PowerAssertionManager.swift` and `Tools Cat/AppDelegate.swift`.
  - Integration method: Native Apple system framework call from `import IOKit.pwr_mgt`
  - Auth: No app-level credentials; access is governed by the macOS app sandbox and code signing context

**External SaaS / Cloud APIs:**
- Not detected - No HTTP clients, API SDKs, or cloud service configuration were found in `Tools Cat/*.swift`, `README.md`, `release.sh`, or `build_dmg.sh`.

## Data Storage

**Databases:**
- None - No database drivers, ORM packages, Core Data model files, or SQLite usage are present in the repo.

**File Storage:**
- Local filesystem only for build artifacts - `release.sh` writes Xcode derived data to `build/`, and `build_dmg.sh` writes packaged output to `dist/`.
  - SDK/Client: Shell tooling in `release.sh` and `build_dmg.sh`
  - Auth: None
  - Buckets/paths: `build/Build/Products/Release/*.app` and `dist/*.dmg`

**Caching:**
- None detected - Application state is transient in SwiftUI/AppKit state objects such as `@State` properties in `Tools Cat/WOLView.swift`.

## Authentication & Identity

**Auth Provider:**
- None - The app has no sign-in flow, token storage, keychain integration, or remote identity provider code.

**OAuth Integrations:**
- None detected

## Monitoring & Observability

**Error Tracking:**
- None - No Sentry, Crashlytics, PLCrashReporter, or similar services are configured in the repo.

**Analytics:**
- None - No analytics SDKs or event pipelines are present.

**Logs:**
- Local stdout / Xcode console logging only - Operational messages for WOL success, interface enumeration, and socket failures use `print(...)` in `Tools Cat/WOLSender.swift`.
  - Integration: Viewed through Xcode or the parent process console; README troubleshooting notes reference Xcode console output in `README.md`

## CI/CD & Deployment

**Hosting:**
- Not applicable - This is a desktop macOS app target defined in `Tools Cat.xcodeproj/project.pbxproj`, not a hosted web or server application.
  - Deployment: Manual local build and packaging via Xcode or `release.sh`
  - Environment vars: Optional local shell overrides only in `release.sh` and `build_dmg.sh`

**CI Pipeline:**
- None detected - No `.github/workflows/`, fastlane configuration, or other CI pipeline files are present at the project root.

## Environment Configuration

**Development:**
- Required env vars: None required to run the app from Xcode according to `README.md`
- Secrets location: Not applicable; no secret files or credential-based integrations were found
- Mock/stub services: Not applicable; tests in `Tools CatTests/` and `Tools CatUITests/` are Xcode template scaffolds only

**Staging:**
- Environment-specific differences: Not applicable
- Data: Not applicable

**Production:**
- Secrets management: Not applicable
- Failover/redundancy: Not applicable for distribution; the only runtime dependency is the local macOS host and local network reachability for WOL

## Webhooks & Callbacks

**Incoming:**
- None - No webhook endpoints, URL handlers, or inbound network listeners are implemented

**Outgoing:**
- Wake-on-LAN UDP broadcast - Triggered from the “发送 WOL …” menu flow in `Tools Cat/StatusBarController.swift`, then executed in `Tools Cat/WOLView.swift` through `WOLSender.send(to:)`.
  - Endpoint: Broadcast IPv4 addresses on UDP port `9` computed from active interfaces in `Tools Cat/WOLSender.swift`
  - Retry logic: No retry queue; the sender iterates all discovered broadcast targets once per user action in `Tools Cat/WOLSender.swift`

---

*Integration audit: 2026-04-11*
