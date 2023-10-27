import Cryptography
import Foundation
import XCTest
@_exported import Derivation

extension SLIP10CurveProtocol {
	static var curveName: String {
		curve.rawValue
	}
}

// MARK: - CAP26Tests
final class CAP26Tests: XCTestCase {

	func test_curve25519_vectors() throws {
		try testFixture(
			bundle: .module,
			jsonName: "cap26_curve25519"
		) { (testGroup: TestGroup) in
			try doTestCAP26(
				group: testGroup,
				curve: Curve25519.self
			)
		}
	}

	func test_secp256k1_vectors() throws {
		try testFixture(
			bundle: .module,
			jsonName: "cap26_secp256k1"
		) { (testGroup: TestGroup) in
			try doTestCAP26(
				group: testGroup,
				curve: SECP256K1.self
			)
		}
	}
	
	
	private func doTestCAP26<Curve>(
		group testGroup: TestGroup,
		curve: Curve.Type
	) throws where Curve: SLIP10CurveProtocol {
		guard curve.curveName == testGroup.curve else {
			XCTFail("Wrong curve specified as generic argument.")
			return
		}
		let mnemonic = try Mnemonic(phrase: testGroup.mnemonic, language: .english)
		let hdRoot = try mnemonic.hdRoot()
		let networkID = try XCTUnwrap(NetworkID(rawValue: UInt8(testGroup.network.networkIDDecimal)))
		func doTest(vector: TestGroup.Test) throws {
			let path = try HD.Path.Full(string: vector.path)
			let keyPair = try hdRoot.derivePrivateKey(path: path, curve: Curve.self)
			let privateKey = try XCTUnwrap(keyPair.privateKey)
			let publicKey = privateKey.publicKey

			XCTAssertEqual(privateKey.rawRepresentation.hex, vector.privateKey)
			XCTAssertEqual(publicKey.compressedRepresentation.hex, vector.publicKey)

			let index = vector.entityIndex
			let entityKind = try XCTUnwrap(EntityKind(rawValue: vector.entityKind))
			guard entityKind == .account else { return } // ignore Personas
			let keyKind = try XCTUnwrap(KeyKind(rawValue: vector.keyKind))
			let entityPath = try AccountBabylonDerivationPath(
				networkID: networkID,
				index: index,
				keyKind: keyKind
			)
			XCTAssertEqual(entityPath.fullPath.toString(), vector.path)
		}

		try testGroup.tests.forEach(doTest(vector:))
	}

}

extension EntityKind {
	var name: String {
		switch self {
		case .account: "ACCOUNT"
		case .identity: "IDENTITY"
		}
	}

	var emoji: String {
		switch self {
		case .account: "💸"
		case .identity: "🎭"
		}
	}
}

extension KeyKind {
	var emoji: String {
		switch self {
		case .transactionSigning: "✍️"
		case .authenticationSigning: "🛂"
		case .messageEncryption: "📨"
		}
	}
}

// MARK: - TestGroup
private struct TestGroup: Sendable, Hashable, Codable {
	let mnemonic: String
	let network: Network
	let curve: String
	struct Network: Sendable, Hashable, Codable {
		let name: String
		let networkIDDecimal: UInt8
	}

	let tests: [Test]
	public struct Test: Sendable, Hashable, Codable {
		let path: String
		let privateKey: String
		let publicKey: String

		let entityKind: UInt32
		let keyKind: UInt32
		let entityIndex: UInt32
	}
}
