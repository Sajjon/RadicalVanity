//
//  SearchTab.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import Foundation
import SwiftUI

@MainActor
struct SearchTab: View {
	@Bindable var model: Model
	var body: some View {
		VStack {
			currentSearch
			errorMessage
			determinismToggle
			textField
			searchButton
			stopButton
		}
		.padding()
		.tabItem { tab }
		.confirmationDialog(
			"Cancel current search?",
			isPresented: $model.isShowingSearchHasRunLongTimeWarning,
			actions: {
				VStack {
					Button("Stop current seach") {
						model.stop(force: true)
					}
					Button("Wait for current search to finish") {
						model.dismissSearchHasRunLongTimeWarning()
					}
				}
			},
			message: { Text("You have been running the current search for \(model.duration.formatted()), are you sure you wanna stop it?") }
		)
	}
}

extension SearchTab {
	@ViewBuilder
	var currentSearch: some View {
		if let searchTask = model.searchTask {
			Text("Searching for: '\(searchTask.target)' #\(model.resultsForCurrentTarget.count) hits")
			ProgressView("Elapsed: \(model.duration.formatted())")
		}
	}
	
	
	@ViewBuilder
	var errorMessage: some View {
		if let error = model.error {
			Text("Error: \(error)")
		}
	}
	
	@ViewBuilder
	var determinismToggle: some View {
		Toggle(isOn: $model.deterministic, label: {
			Text("Deterministic (Unsafe if checked - same initial state every time)")
		})
		.disabled(model.searchTask != nil)
	}
	
	
	@ViewBuilder
	var textField: some View {
		TextField("Target", text: $model.target)
		#if os(iOS)
			.textInputAutocapitalization(.never)
		#endif
			.textCase(.lowercase)
	}
	
	@ViewBuilder
	var searchButton: some View {
		Button("Find") {
			model.start(force: false)
		}
	}
	
	@ViewBuilder
	var stopButton: some View {
		if model.canStop {
			Button("Stop") {
				model.stop(force: false)
			}
		}
	}
	
	@ViewBuilder
	var tab: some View {
		if let currentTarget = model.searchTask?.target {
			Label("\"\(currentTarget)\"", systemImage: "hourglass.and.lock")
		} else {
			Label("Search", systemImage: "plus.magnifyingglass")
		}
	}
}
