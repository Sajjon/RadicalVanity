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
			AddressView(address: summary.address)
			VStack {
				labelled("Mnemonic", \.mnemonic)
				Button("Copy") {
					copyToPasteboard(summary.mnemonic)
					markSeen(result.id)
				}
			}
			labelled("Derivation Path", \.derivationPath)
			if !result.result.details.accountsAtLowerIndex.isEmpty {
				VStack(alignment: .leading) {
					Text("Accounts at lower index")
						.font(.caption2)
					ForEach(self.result.result.details.accountsAtLowerIndex, id: \.self) { acc in
						VStack(alignment: .leading) {
							Labelled("index", acc.index)
							AddressView(address: acc.address)
						}
						.font(.footnote)
					}
				}
			}
		}
		.padding()
		.border(Color.blue, width: 2)
		.background(isNew ? .green : .white)
		.padding()
	}
}

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
public func copyToPasteboard(_ contents: String) {
	#if os(iOS)
	UIPasteboard.general.string = contents
	#elseif os(macOS)
	NSPasteboard.general.clearContents()
	NSPasteboard.general.declareTypes([.string], owner: nil)
	NSPasteboard.general.setString(contents, forType: .string)
	#endif
}

struct AddressView: View {
	let address: String
	var condAddr: String {
		if isShowingFull {
			address
		} else {
			abbreviated(address: address)
		}
	}
	@State var isShowingFull = false
	var body: some View {
		Text("`\(condAddr)`")
			.contextMenu {
				if isShowingFull {
					Button("Hide full") {
						isShowingFull = false
					}
				} else {
					Button("View full") {
						isShowingFull = true
					}
				}
				Button("Copy") {
					copyToPasteboard(address)
				}
				
			}
	}

}
