import XCTest
@testable import RadicalVanity

final class RadicalVanityTests: XCTestCase {
	
	func test_find_invalid_char_throws() {
		XCTAssertThrowsError(
			try findMnemonicFor(suffix: "bo")
		)
	}
	
}
