// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RadicalVanity",
	platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RadicalVanity",
            targets: ["RadicalVanity"]),
    ],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.4.0"),
		.package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
		.package(url: "https://github.com/radixdlt/swift-engine-toolkit", from: "1.0.0-bbfaef1"),
		.package(url: "https://github.com/apple/swift-collections", branch: "main"),
		.package(url: "https://github.com/sajjon/k1", from: "0.3.9"),
		.package(url: "https://github.com/attaswift/BigInt", from: "5.3.0"),
		.package(url: "https://github.com/apple/swift-algorithms", from: "1.1.0"),
	],
    targets: [
        .target(
            name: "Cryptography",
			dependencies: [
				.product(name: "NonEmpty", package: "swift-nonempty"),
				.product(name: "Collections", package: "swift-collections"),
				.product(name: "BigInt", package: "BigInt"),
				.product(name: "K1", package: "k1"),
				.product(name: "Algorithms", package: "swift-algorithms"),
			]
		),
		.testTarget(
			name: "CryptographyTests",
			dependencies: ["Cryptography"],
			resources: [.process("TestVectors/")]
		),
		.target(
			name: "Derivation",
			dependencies: [
				"Cryptography",
				.product(name: "EngineToolkit", package: "swift-engine-toolkit"),
				.product(name: "Tagged", package: "swift-tagged"),
			]),
		.testTarget(
			name: "DerivationTests",
			dependencies: ["Derivation"],
			resources: [.process("TestVectors/")]
		),
		.target(
			name: "RadicalVanity",
			dependencies: ["Derivation"]
		),
        .testTarget(
            name: "RadicalVanityTests",
            dependencies: ["RadicalVanity"]),
    ]
)
