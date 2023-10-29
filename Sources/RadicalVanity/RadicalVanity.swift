@_exported import Derivation


public func abbreviated(address: String) -> String {
	[
		address.prefix(4),
		address.suffix(6),
	]
		.map(String.init)
		.joined(separator: "...")
}


public struct AccountsAtLowerIndex: Sendable, Hashable {
	public let index: UInt32
	public let address: String
}

public struct Vanity: Sendable, Hashable, CustomStringConvertible {
	public let mnemonic: Mnemonic
	public let address: String
	public let details: Details
	public let input: Input
	public struct Details: Sendable, Hashable {
		public let derivationPath: String
		public let privateKey: Curve25519.PrivateKey
		public let accountsAtLowerIndex: [AccountsAtLowerIndex]
	}
	public struct Input: Sendable, Hashable {
		public let targetSuffix: String
		public let maxDerivationIndexPerMnemonicAttempt: HD.Path.Component.Child.Value
	}
	public var summary: Summary {
		.init(
			address: address,
			targetSuffix: input.targetSuffix,
			mnemonic: mnemonic.phrase.rawValue,
			derivationPath: details.derivationPath,
			accountsAtLowerIndex: details.accountsAtLowerIndex
		)
	}
	public struct Summary: Sendable, Equatable, CustomStringConvertible {
		public let address: String
		public let targetSuffix: String
		public let mnemonic: String
		public let derivationPath: String
		public let accountsAtLowerIndex: [AccountsAtLowerIndex]
		
		public var description: String {
			let count = 10
			let lowerIndicesAddresses: String = {
				guard !accountsAtLowerIndex.isEmpty else {
					return ""
				}
				let separator = String(repeating: "🔮", count: count)
				let mapped = accountsAtLowerIndex.map {
					"\(abbreviated(address: $0.address)) @ \($0.index) 🔮"
				}
				return "\n\(separator)\n\(mapped.joined(separator: "\n"))"
			}()
			let separator = String(repeating: "✨", count: count)
 return """
 \n\n\(separator)
 Address: '\(address)' (🎯: '\(targetSuffix)')
 Mnemonic: '\(mnemonic)'
 DerivationPath: '\(derivationPath)'\(lowerIndicesAddresses)
 \(separator)
 """
		}
	}
	public var description: String {
		summary.description
	}
}

public let bech32Alphabet = Set("023456789acdefghjklmnpqrstuvwxyz")

extension BigUInt: @unchecked Sendable {}
public typealias AttemptCount = BigUInt

enum Error: Swift.Error {
	case invalidLetter(Character)
	case noResultAfter(attempts: AttemptCount)
}

public func validate(suffix targetSuffix: String) throws {
	let invalidCharacterSet = Set(targetSuffix).subtracting(bech32Alphabet)
	
	if let invalidCharacter = invalidCharacterSet.first {
		throw Error.invalidLetter(invalidCharacter)
	}
	
	// all good
}

/// Attempts to find a mnemonic for an address ending with `suffix`
public func findMnemonicFor(
	suffix targetSuffix: String,
	deterministic: Bool = false,
	maxDerivationIndexPerMnemonicAttempt: HD.Path.Component.Child.Value = 20,
	onResult: @Sendable (Vanity) async throws -> Void
) async throws {
	try validate(suffix: targetSuffix)
	var mnemonic: Mnemonic!
	var hdRoot: HD.Root!
	
	var rawSeed: BigUInt = try {
		if deterministic {
			return 0
		} else {
			return try BigUInt(SecureBytesGenerator.generate(byteCount: 31).hex, radix: 16)!
		}
	}()
	
	while true {
		defer {
			rawSeed += 1
		}
		mnemonic = try Mnemonic(
			entropy: .init(data: rawSeed.data(byteCount: 32)),
			language: .english
		)
		hdRoot = try mnemonic.hdRoot()
		let network: NetworkID = .mainnet
		var accountsAtLowerIndex: [AccountsAtLowerIndex] = []
		for index in 0..<maxDerivationIndexPerMnemonicAttempt {
			let derivationPath = try AccountBabylonDerivationPath(
				networkID: network,
				index: index,
				keyKind: .transactionSigning
			)
			let privateKey = try hdRoot.derivePrivateKey(path: derivationPath.fullPath, curve: Curve25519.self)
			let publicKey = privateKey.publicKey
			let addressObj = try deriveVirtualAccountAddressFromPublicKey(
				publicKey: .ed25519(value: [UInt8](publicKey.compressedRepresentation)),
				networkId: network.rawValue
			)
			let address = addressObj.asStr()
			if address.hasSuffix(targetSuffix) {
				let result = Vanity(
					mnemonic: mnemonic,
					address: address,
					details: .init(
						derivationPath: derivationPath.fullPath.toString(),
						privateKey: privateKey.privateKey!,
						accountsAtLowerIndex: accountsAtLowerIndex
					),
					input: .init(
						targetSuffix: targetSuffix,
						maxDerivationIndexPerMnemonicAttempt: maxDerivationIndexPerMnemonicAttempt
					)
				)
				try await onResult(result)
			} else {
				accountsAtLowerIndex.append(
					AccountsAtLowerIndex(
						index: index,
						address: address
					)
				)
			}
		}
	}
	
}

extension BigUInt {
	func data(pad: UInt8 = 0x00, byteCount toLength: Int) -> Data {
		var serialized = serialize()
		if serialized.count == toLength {
			return serialized
		} else if serialized.count > toLength {
			return Data(serialized.prefix(32))
		}
		let bytesToPad = toLength - serialized.count
		let bytes: [UInt8] = .init(repeating: pad, count: bytesToPad)
		serialized.append(contentsOf: bytes)
		return serialized
	}
}
