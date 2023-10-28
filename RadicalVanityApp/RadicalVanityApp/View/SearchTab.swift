//
//  SearchTab.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import Foundation
import SwiftUI

struct SearchTab: View {
	@Bindable var model: Model
	var body: some View {
		VStack {
			if let searchTask = model.searchTask {
				Text("Searching for: '\(searchTask.target)' #\(model.resultsForCurrentTarget.count) hits")
				ProgressView("Elapsed: \(model.duration.formatted())")
			}
			
			if let error = model.error {
				Text("Error: \(error)")
			}
			
			Toggle(isOn: $model.deterministic, label: {
				Text("Deterministic")
			})
			
			TextField("Target", text: $model.target)
			#if os(iOS)
				.textInputAutocapitalization(.never)
			#endif
				.textCase(.lowercase)
			
			Button("Find") {
				model.start(force: false)
			}
			.disabled(!model.canSearch)
			
			Button("Stop") {
				model.stop(force: false)
			}
			.disabled(!model.canStop)
		}
		.padding()
		.tabItem {
			if let currentTarget = model.searchTask?.target {
				Label("\"\(currentTarget)\"", systemImage: "hourglass.and.lock")
			} else {
				Label("Search", systemImage: "plus.magnifyingglass")
			}
		}
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
