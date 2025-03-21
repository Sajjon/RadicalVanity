import EngineToolkit

// MARK: - EntityKind
/// A kind of entity, e.g. the kind `account` or the kind `identity` (used by Persona), used in derivation path scheme.
public enum EntityKind:
	HD.Path.Component.Child.Value,
	SLIP10DerivationPathComponent,
	Sendable,
	Hashable,
	Codable,
	CustomStringConvertible
{
	/// An account entity type
	case account = 525

	/// Used by Persona
	case identity = 618

	
}

extension EntityKind {
	public var description: String {
		switch self {
		case .account: "account"
		case .identity: "identity"
		}
	}
}
