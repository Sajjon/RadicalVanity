import Derivation

public struct Vanity: Hashable {
	public let mnemonic: Mnemonic
	public let address: String
	public let details: Details
	public let input: Input
	public struct Details: Hashable {
		public let derivationPath: String
		public let privateKey: Curve25519.PrivateKey
		public let elapsedTime: TimeInterval
	}
	public struct Input: Hashable {
		public let targetSuffix: String
		public let attempt: AttemptCount
		public let maxAttempts: AttemptCount
		public let maxDerivationIndexPerMnemonicAttempt: HD.Path.Component.Child.Value
	}
}

public let bech32Alphabet = Set("023456789acdefghjklmnpqrstuvwxyz")

public typealias AttemptCount = BigUInt

enum Error: Swift.Error {
	case invalidLetter(Character)
	case noResultAfter(attempts: AttemptCount)
}

/// Attempts to find a mnemonic for an address ending with `suffix`
public func findMnemonicFor(
	suffix targetSuffix: String,
	maxDerivationIndexPerMnemonicAttempt: HD.Path.Component.Child.Value = 10,
	attempts maxAttempts: AttemptCount = 100_000
) throws -> Vanity {
	var attempt: AttemptCount = 0
	let invalidCharacterSet = Set(targetSuffix).subtracting(bech32Alphabet)
	
	if let invalidCharacter = invalidCharacterSet.first {
		throw Error.invalidLetter(invalidCharacter)
	}
	
	var mnemonic: Mnemonic!
	var hdRoot: HD.Root!
	let timeStart = DispatchTime.now()
	while attempt < maxAttempts {
		defer { attempt += 1 }
		if attempt.isMultiple(of: 100) {
			print("⏳ \(attempt) Mnemonics tried")
		}
		if attempt >= maxAttempts {
			throw Error.noResultAfter(attempts: maxAttempts)
		}
		mnemonic = try Mnemonic(
			entropy: .init(data: attempt.data(byteCount: 32)),
			language: .english
		)
		hdRoot = try mnemonic.hdRoot()
		let network: NetworkID = .mainnet
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
				let timeEnd = DispatchTime.now()
				let nanoTime = timeEnd.uptimeNanoseconds - timeStart.uptimeNanoseconds // << Difference in nano seconds (UInt64)
				let elapsedTime = TimeInterval(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests

				return Vanity.init(
					mnemonic: mnemonic,
					address: address,
					details: .init(
						derivationPath: derivationPath.fullPath.toString(),
						privateKey: privateKey.privateKey!,
						elapsedTime: elapsedTime
					),
					input: .init(
						targetSuffix: targetSuffix,
						attempt: attempt,
						maxAttempts: maxAttempts,
						maxDerivationIndexPerMnemonicAttempt: maxDerivationIndexPerMnemonicAttempt
					)
				)
			}
		}
	}
	
	throw Error.noResultAfter(attempts: attempt)
}

extension BigUInt {
	func data(pad: UInt8 = 0x00, byteCount toLength: Int) -> Data {
		var serialized = serialize()
		if serialized.count >= toLength {
			return serialized
		}
		let bytesToPad = toLength - serialized.count
		let bytes: [UInt8] = .init(repeating: pad, count: bytesToPad)
		serialized.append(contentsOf: bytes)
		return serialized
	}
	/*
	 
	 /// Return a `Data` value that contains the base-256 representation of this integer, in network (big-endian) byte order.
  public func serialize() -> Data {
	  // This assumes Digit is binary.
	  precondition(Word.bitWidth % 8 == 0)

	  let byteCount = (self.bitWidth + 7) / 8

	  guard byteCount > 0 else { return Data() }

	  var data = Data(count: byteCount)
	  data.withUnsafeMutableBytes { buffPtr in
		  let p = buffPtr.bindMemory(to: UInt8.self)
		  var i = byteCount - 1
		  for var word in self.words {
			  for _ in 0 ..< Word.bitWidth / 8 {
				  p[i] = UInt8(word & 0xFF)
				  word >>= 8
				  if i == 0 {
					  assert(word == 0)
					  break
				  }
				  i -= 1
			  }
		  }
	  }
	  return data
  }
	 */
}
