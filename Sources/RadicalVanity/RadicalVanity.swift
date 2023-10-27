import Cryptography

public struct Vanity {
	public let mnemonic: Mnemonic
	public let address: String
	public let derivationPath: String
}

public func findMnemonic(targetAddressSuffix: String) -> Result<Vanity, Error> {
	fatalError()
}
