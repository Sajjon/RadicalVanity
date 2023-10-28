//
//  ResultTab.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import Foundation
import SwiftUI

struct ResultTab: View {
	@Bindable var model: Model
	var body: some View {
		VStack {
			Button("Mark all as seen") {
				model.markAllAsSeen()
			}
			.disabled(model.newResults.isEmpty)
			
			Button("Clear results") {
				model.clearResults()
			}
			.disabled(model.results.isEmpty)
			
			ScrollView {
				VStack {
					ForEach(model.results, id: \.self) { result in
						ResultView(result: result) { id in
							model.markSeen(id: id)
						}
					}
				}
			}
		}
		.badge(model.newResults.count)
		.tabItem { Label("Results", systemImage: "list.star") }
		.alert(isPresented: $model.isShowingAreYouSureWannaClearResultsWarning, error: ClearResultsWarning(), actions: {
			VStack {
				Button("No") {
					model.isShowingAreYouSureWannaClearResultsWarning = false
				}
				Button("Yes") {
					model.doClearResults()
				}
			}
		})
		.padding()
	}
}

struct ClearResultsWarning: LocalizedError {
	var errorDescription: String? {
		"Are you sure you wanna clear results?"
	}
}
