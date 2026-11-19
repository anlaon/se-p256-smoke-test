# Secure Enclave P-256 Smoke Test (iOS Simulator)

Minimal Xcode project that runs a Secure Enclave P-256 smoke test in the
iOS Simulator on a free GitHub Actions macOS runner.

## ⚠️ SIMULATOR ONLY — read this first

**Secure Enclave is simulated here, NOT real hardware.** This project only
verifies that the Swift / CryptoKit test code **compiles and its logic
runs**. It does **NOT** prove the real Secure Enclave on a physical iPhone
works. A real-hardware test on a physical iPhone remains a separate step:
it needs a Mac + a physical iPhone.

## What the test does

1. Create a P-256 signing key in the (simulated) Secure Enclave.
2. Sign the fixed message `"smoke-test-message"` and verify with the
   exported public key; the signature must be 64-byte raw `r||s`.
3. Public key must be a 65-byte uncompressed point (`0x04 || x || y`).
4. Non-exportability: `SecureEnclave.P256.Signing.PrivateKey` provides no
   API returning the private scalar — recorded as "no API by design".
5. Reverse control: CryptoKit exposes no Secure Enclave Ed25519 type —
   recorded as "unavailable by design".

## Layout (this directory is the repo root when pushed)

```
SEP256SmokeTest/               Xcode project (app + unit-test targets)
  SEP256SmokeTest.xcodeproj/
    project.pbxproj
    xcshareddata/xcschemes/SEP256SmokeTest.xcscheme  (shared scheme)
  SEP256SmokeTest/SEP256SmokeTestApp.swift   minimal SwiftUI host app
  SEP256SmokeTestTests/SEP256SmokeTestTests.swift    XCTest cases
.github/workflows/se-p256-smoke-test.yml     GitHub Actions workflow
```

Decisions:

- **XCTest, not a bare app**: `xcodebuild test` is the standard CI path; it
  builds the host app, installs it in the Simulator, runs the tests, and
  reports pass/fail in the log.
- **One app target + one test target**, no storyboards, no asset catalog,
  no external dependencies. `GENERATE_INFOPLIST_FILE = YES`, so no
  Info.plist files are needed. Only system frameworks (CryptoKit,
  Security) are linked into the test target; XCTest is auto-linked.
- **iOS 17.0 deployment target**, Swift 5.0, bundle ID
  `com.example.sep256smoketest` (test bundle:
  `com.example.sep256smoketest.tests`).
- **Simulator: iPhone 15, latest iOS** (`OS=latest`).
- **Xcode**: prefers Xcode 16.2 if present on the runner, else the default
  Xcode. Runner: `macos-latest`.
- **No code signing**: the workflow passes
  `CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`
  (Simulator builds need no signing). No development team, no secrets.
- Test output lines are prefixed `SE-TEST:` so they are easy to
  find in the CI log; the workflow greps them out at the end.

## Run locally (on a Mac)

```sh
cd SEP256SmokeTest
xcodebuild test \
  -project SEP256SmokeTest.xcodeproj \
  -scheme SEP256SmokeTest \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## Push to GitHub

The repo must be **PUBLIC** so GitHub Actions macOS runners are free and
unlimited (private repos get ~193 macOS minutes/month on the Free plan).
Push the *contents* of this directory as the repo root (e.g. repo
`anlaon/se-p256-smoke-test`), on branch `main`. The workflow runs on
push, on pull requests touching these files, and manually
(`workflow_dispatch`).

## Known limits

- Simulator Secure Enclave is a software simulation; a pass here is a
  code-correctness check only, never a hardware result.
- Each CI run creates a fresh Secure Enclave key in the simulated
  keychain; the test does not delete it (the runner is ephemeral).
- If `iPhone 15` is not available on a future runner image, change the
  `-destination` name in the workflow (the "List available simulators"
  step prints what exists).
