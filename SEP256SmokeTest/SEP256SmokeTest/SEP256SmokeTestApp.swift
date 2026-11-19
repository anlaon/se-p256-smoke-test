import SwiftUI

/// Minimal host app for the Secure Enclave P-256 smoke-test bundle.
/// The real checks live in SEP256SmokeTestTests (XCTest); this app only hosts them.
/// Run the checks with: xcodebuild test -project SEP256SmokeTest.xcodeproj -scheme SEP256SmokeTest
///   -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
@main
struct SEP256SmokeTestApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 12) {
                Text("Secure Enclave P-256 Smoke Test")
                    .font(.headline)
                Text("Run via Xcode Test. Results print to the test log.")
                Text("SIMULATOR — Secure Enclave simulated, NOT real hardware.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
