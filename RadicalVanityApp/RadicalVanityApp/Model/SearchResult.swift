//
//  File.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import Foundation
import RadicalVanity

public struct SearchResult: Hashable, Identifiable {
	public var isNew: Bool
	public var id: String { result.address }
	public let result: Vanity
	init(isNew: Bool = true, result: Vanity) {
		self.isNew = isNew
		self.result = result
	}
	mutating func seen() {
		isNew = false
	}
}
