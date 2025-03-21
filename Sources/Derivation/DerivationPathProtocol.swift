import EngineToolkit

// MARK: - DerivationScheme
/// A derivation scheme used to derive keys using some derivation path.
public enum DerivationScheme:
	String,
	Sendable,
	Hashable,
	Codable
{
	/// SLIP-10 derivation scheme as detail in https://github.com/satoshilabs/slips/blob/master/slip-0010.md
	case slip10

	/// BIP-44 derivation scheme as detail in https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
	case bip44
}

// MARK: - DerivationPathProtocol
/// A type which holds a `derivationPath` used for HD key derivation.
public protocol DerivationPathProtocol {
	var derivationPath: String { get }
	init(derivationPath: String) throws

	/// Wraps this specific type of derivation path to the shared
	/// nominal type `DerivationPath` (enum)
	func wrapAsDerivationPath() -> DerivationPath

	/// Tries to unwraps the nominal type `DerivationPath` (enum)
	/// into this specific type.
	static func unwrap(derivationPath: DerivationPath) -> Self?
}

extension DerivationPathProtocol {
	public init(path: HD.Path.Full) throws {
		try self.init(derivationPath: path.toString())
	}
}

// MARK: - DerivationPathSchemeProtocol
/// A type which holds a `derivationPath` acting as input for key derivation
/// using the `derivationScheme`.
public protocol DerivationPathSchemeProtocol: DerivationPathProtocol {
	static var derivationScheme: DerivationScheme { get }
}

// MARK: - DerivationPathPurposeProtocol
/// A type which has a purpose to derive keys at the `derivationPath`.
public protocol DerivationPathPurposeProtocol: DerivationPathProtocol {
}

extension DerivationPathProtocol where Self: Identifiable, ID == String {
	public var id: String { derivationPath }
}

// MARK: - DerivationPath
/// A derivation path used to derive keys for Accounts and Identities for signing of
/// transactions and authentication.
public struct DerivationPath:
	Sendable,
	Hashable,
	Codable,
	CustomStringConvertible
{
	public let scheme: DerivationPathScheme
	public let path: String
	public var curveForScheme: SLIP10.Curve {
		scheme.curve
	}

	public init(scheme: DerivationPathScheme, path: String) {
		self.scheme = scheme
		self.path = path
	}
}
//
extension DerivationPath {
//	public static let getID: Self = try! .customPath(.init(path: .getID), scheme: .cap26)
//
	/// The **default** derivation path for `Account`s.
	public static func accountPath(_ path: AccountBabylonDerivationPath) -> Self {
		Self(scheme: .cap26, path: path.fullPath.toString())
	}
//
//	/// The **default** derivation path for `Identities`s (Personas).
//	public static func identityPath(_ path: IdentityHierarchicalDeterministicDerivationPath) -> Self {
//		Self(scheme: .cap26, path: path.derivationPath)
//	}
//
//	/// A **custom** derivation path use to derive some keys.
//	public static func customPath(_ path: CustomHierarchicalDeterministicDerivationPath, scheme: DerivationPathScheme) -> Self {
//		Self(scheme: scheme, path: path.derivationPath)
//	}
//
//	public static func forEntity(
//		kind entityKind: EntityKind,
//		networkID: Radix.Network.ID,
//		index: HD.Path.Component.Child.Value,
//		keyKind: KeyKind = .virtualEntity
//	) throws -> Self {
//		let path = try HD.Path.Full.defaultForEntity(
//			networkID: networkID,
//			entityKind: entityKind,
//			index: index,
//			keyKind: keyKind
//		)
//		return Self(scheme: .cap26, path: path.toString())
//	}
}

//extension DerivationPath {
//	// FIXME: Multifactor remove
//	@available(*, deprecated, message: "Use 'path' instead")
//	public var derivationPath: String {
//		path
//	}
//
//	public func asIdentityPath() throws -> IdentityHierarchicalDeterministicDerivationPath {
//		try IdentityHierarchicalDeterministicDerivationPath(derivationPath: path)
//	}
//
//	public func asAccountPath() throws -> AccountDerivationPath {
//		try AccountDerivationPath(derivationPath: path)
//	}
//
//	public func asCustomPath() throws -> CustomHierarchicalDeterministicDerivationPath {
//		try CustomHierarchicalDeterministicDerivationPath(derivationPath: path)
//	}
//
//	public func asLegacyOlympiaBIP44LikePath() throws -> LegacyOlympiaBIP44LikeDerivationPath {
//		try LegacyOlympiaBIP44LikeDerivationPath(derivationPath: path)
//	}
//}

extension DerivationPath {
	public func hdFullPath() throws -> HD.Path.Full {
		try .init(string: path)
	}
}

extension DerivationPath {
	public var customDumpDescription: String {
		_description
	}

	public var description: String {
		_description
	}

	public var _description: String {
		path
	}
}
