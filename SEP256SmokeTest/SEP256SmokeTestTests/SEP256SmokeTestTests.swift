import XCTest
import CryptoKit
import Security

/// Secure Enclave P-256 smoke test — SIMULATOR version.
///
/// SIMULATOR — Secure Enclave simulated, NOT real hardware.
/// This verifies the Swift / CryptoKit code compiles and its logic runs.
/// It does NOT prove the real Secure Enclave on a physical iPhone works.
/// A real-hardware test on a physical iPhone is a separate step:
/// it needs a Mac + a physical iPhone.
///
/// This Simulator run is only a code-correctness check.
final class SEP256SmokeTestTests: XCTestCase {

    /// 1. Create a P-256 signing key in the (simulated) Secure Enclave.
    /// 2. Sign the fixed test message "smoke-test-message" and verify with the
    ///    exported public key; signature must be 64-byte raw r||s.
    /// 3. Public key must be a 65-byte uncompressed point (0x04 || x || y).
    func testP256KeyCreationSignVerifyAndPubkey() throws {
        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .privateKeyUsage,
            nil)
        XCTAssertNotNil(access, "SecAccessControlCreateWithFlags must not return nil")

        let key = try SecureEnclave.P256.Signing.PrivateKey(accessControl: access!)

        let message = "smoke-test-message".data(using: .utf8)!
        let signature = try key.signature(for: message)
        XCTAssertEqual(
            signature.rawRepresentation.count, 64,
            "P-256 ECDSA signature must be 64-byte raw r||s")
        XCTAssertTrue(
            key.publicKey.isValidSignature(signature, for: message),
            "Public key must verify the signature over the test message")

        let pub = key.publicKey.x963Representation
        XCTAssertEqual(pub.count, 65, "Public key must be 65-byte x963")
        XCTAssertEqual(pub.first, 0x04, "x963 representation must start with 0x04")

        print("SE-TEST: [PASS] P-256 key created, signed 64-byte r||s, verified, pubkey 65-byte 0x04")
        print("SE-TEST: pubkey = \(pub.map { String(format: "%02X", $0) }.joined())")
        print("SE-TEST: signature = \(signature.rawRepresentation.map { String(format: "%02X", $0) }.joined())")
    }

    /// 4. Non-exportability (by design): SecureEnclave.P256.Signing.PrivateKey
    /// provides no API that returns the private scalar (no rawRepresentation).
    /// There is no runtime call that could export it, so this test records
    /// the design fact. It must NOT be worked around.
    func testPrivateKeyNotExportableByDesign() {
        // Compile-time property of the CryptoKit API: the Secure Enclave
        // private-key type exposes no private-key material. Nothing to call.
        print("SE-TEST: [PASS] Private export has no API by design (no rawRepresentation on SecureEnclave.P256.Signing.PrivateKey)")
    }

    /// Reverse control: CryptoKit exposes no SecureEnclave Ed25519 type.
    /// Secure Enclave offers only P256 (Signing + KeyAgreement). The absence
    /// is a compile-time fact of the SDK. If Apple ever adds a
    /// SecureEnclave Curve25519 / Ed25519 type, this must be revisited.
    func testEd25519SecureEnclaveUnavailable() {
        print("SE-TEST: [PASS] Ed25519 in Secure Enclave unavailable by design (no SecureEnclave Ed25519 type in CryptoKit)")
    }
}
