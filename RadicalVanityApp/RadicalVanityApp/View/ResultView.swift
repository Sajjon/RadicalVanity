//
//  ResultView.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import SwiftUI
import RadicalVanity

struct Labelled: View {
	let key: String
	let value: String
	let vertical: Bool
	init<Value>(
		_ key: String,
		_ value: Value,
		vertical: Bool = true
	) where Value: CustomStringConvertible {
		self.key = key
		self.value = String(describing: value)
		self.vertical = vertical
	}
	
	@ViewBuilder
	var content: some View {
		Text("**\(key)**")
		Text("*\(value)*")
			.textSelection(.enabled)
			.multilineTextAlignment(.leading)
	}
	
	var body: some View {
		if vertical {
			VStack(alignment: .leading) {
				content
			}
		} else {
			HStack {
				content
			}
		}
	}
}

struct ResultView: View {
	let result: SearchResult
	
	var summary: Vanity.Summary { result.result.summary }
	var isNew: Bool { result.isNew }
	var markSeen: (SearchResult.ID) -> Void
	
	func labelled<Value>(
		_ key: String, _
		keyPath: KeyPath<Vanity.Summary, Value>,
		vertical: Bool = true
	) -> Labelled where Value: CustomStringConvertible {
		Labelled(key, summary[keyPath: keyPath], vertical: vertical)
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			labelled("Target", \.targetSuffix, vertical: false)
			labelled("Address", \.address)
			VStack {
				labelled("Mnemonic", \.mnemonic)
				Button("Copy") {
					UIPasteboard.general.string = summary.mnemonic
					markSeen(result.id)
				}
			}
			labelled("Derivation Path", \.derivationPath)
		}
		.padding()
		.border(Color.blue, width: 2)
		.background(isNew ? .green : .white)
		.padding()
	}
}
