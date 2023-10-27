public struct Vanity: Sendable, Hashable {
	public let mnemonic: Mnemonic
	public let address: String
	public let derivationPath: String
}

public let bech32Alphabet = Set("qpzry9x8gf2tvdw0s3jn54khce6mua7l")

public typealias AttemptCount = UInt64

enum Error: Swift.Error {
	case invalidLetter(Character)
	case noResultAfter(attempts: AttemptCount)
}

/// Attempts to find a mnemonic for an address ending with `suffix`
public func findMnemonicFor(
	suffix target: String,
	attempts: AttemptCount = 1000
) throws -> Vanity {
	let invalidCharacterSet = Set(target).subtracting(bech32Alphabet)
	
	if let invalidCharacter = invalidCharacterSet.first {
		throw Error.invalidLetter(invalidCharacter)
	}
	
	throw Error.noResultAfter(attempts: attempts)
}
