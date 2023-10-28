import XCTest
@testable import RadicalVanity

final class RadicalVanityTests: XCTestCase {
	
	func test_find_invalid_char_throws() {
		XCTAssertThrowsError(
			try findMnemonicFor(suffix: "bo")
		)
	}
	func test_alphabet() {
		XCTAssertEqual(
			Set("qpzry9x8gf2tvdw0s3jn54khce6mua7l"),
			Set("023456789acdefghjklmnpqrstuvwxyz")
		)
	}
	func test_xrd() throws {
		// start at `0` (not random... duh).
		let result = try findMnemonicFor(suffix: "xrd")
		let summary = result.summary
		XCTAssertEqual(summary.address, "account_rdx12x5yc244q2ex7aw06dcnlduw2re556h797afg89ksjy9vnkzms9xrd")
		XCTAssertEqual(summary.mnemonic, "action job abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon body")
	}
	func test_cy0n() throws {
		let result = try findMnemonicFor(suffix: "cy0n")
		print(result)
	}
	func test_alex() throws {
		let result = try findMnemonicFor(suffix: "alex")
		print(result)
	}
	func test_klara() throws {
		let result = try findMnemonicFor(suffix: "klara")
		print(result)
	}
}
//func test_bits() {
//	let size = 4
//	precondition(size <= 16)
//	let sut = Bits(size: size)
//	let combinations = UInt64(BigInt(2).power(size))
//	for _ in 0..<combinations {
//		print(sut)
//		sut.increment()
//	}
//}
//final class Bits: CustomStringConvertible {
//	private var currentIndex: Int
//	public let size: Int
//	public private(set) var targetIndex: Int
//	public private(set) var bitArray: BitArray
//	public var description: String {
//		bitArray.binaryString
//	}
//	init(size: Int) {
//		self.size = size
//		self.currentIndex = 0
//		self.targetIndex = size - 1
//		self.bitArray = BitArray(repeating: false, count: size)
//	}
//
//	/// Example of 8 bits, this function does this:
//	///
//	/// 	0000_0000
//	/// 	0000_0001
//	/// 	0000_0010
//	/// 	0000_0100
//	/// 	0000_1000
//	/// 	0001_0000
//	/// 	0010_0000
//	/// 	0100_0000
//	/// 	1000_0000
//	/// 	1000_0001
//	/// 	1000_0010
//	/// 	1000_0100
//	/// 	1000_1000
//	/// 	1001_0000
//	/// 	1010_0000
//	/// 	1100_0000
//	/// 	1100_0001
//	/// 	1100_0010
//	///		.........
//	///		.........
//	///		.........
//	///		1111_1000
//	///		1111_1001
//	///		1111_1010
//	///		1111_1100
//	///		1111_1101
//	///		1111_1110
//	///		1111_1111
//	@discardableResult func increment() -> BitArray? {
//		let lastIndex = currentIndex - 1
//		if lastIndex > 0 {
//			bitArray[lastIndex] = false
//		}
//		bitArray[currentIndex] = true
//		currentIndex += 1
//		if currentIndex == targetIndex {
//			targetIndex -= 1
//			if targetIndex == 0 {
//				return bitArray
//			}
//			currentIndex = 0
//		}
//		return nil
//	}
//}
