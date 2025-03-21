//
//  CLI.swift
//  
//
//  Created by Alexander Cyon on 2023-10-29.
//

import Foundation
import RadicalVanity
import ArgumentParser

@main
struct RadicalVanityCLI: AsyncParsableCommand {
	@Flag(help: "Unsafe if true, if you want to always start at same initial state.")
	var deterministic = false
	
	@Flag(help: "Set to true if you want to stop searching after finding a vanity address/mnemonic/derivation tripple.")
	var single = false

	@Option(name: .shortAndLong, help: "The maximum derivation index to use per mnemonic attempt, meaning a vanity address matching 'target' suffix might be found at index 7, not 0. Higher value leads to faster search.")
	var indices: Int = 10

	@Argument(help: "Suffixes of vanity Radix addresses to find mnemonic and derivation path for, comma seperated list, e.g. \"xrd,test\"")
	var targets: String

	mutating func run() async throws {
		print("🔮 Searching for `\(targets)` 🔮")
		if deterministic {
			print("⚠️ WARNING determinism used, unsafe. ⚠️")
		}
		let targetList = splitIntoTargets(commaSeperatedString: targets)
		for target in targetList {
			guard target.count >= 1 else {
				throw Error.targetSuffixLengthMustBeGreaterThanZero
			}
			guard target.count < 7 else {
				throw Error.targetSuffixLengthMustBeShorterThanSeven
			}
		}
		guard indices >= 1 else {
			throw Error.indicesMustBeGreaterThanZero
		}
		try await search(targets: targetList)
	}
	
	func search(targets: [String]) async throws {
		
		try await findMnemonicFor(
			targets: targets,
			deterministic: deterministic,
			maxDerivationIndexPerMnemonicAttempt: .init(indices - 1)
		) { vanity in
			print(vanity)
			guard !single else {
				throw Error.finishedSinceFlagManyWasFalse
			}
		}
		
	}
}

extension RadicalVanityCLI {
	enum Error: Swift.Error {
		case targetSuffixLengthMustBeShorterThanSeven
		case targetSuffixLengthMustBeGreaterThanZero
		case indicesMustBeGreaterThanZero
		case finishedSinceFlagManyWasFalse
	}
}
