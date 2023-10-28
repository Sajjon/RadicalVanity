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
			if model.canStop {
				Text("Searching for: '\(model.target)'")
				ProgressView("Elapsed: \(model.duration.formatted())")
			}
			
			if let error = model.error {
				Text("Error: \(error)")
			}
			
			TextField("Target", text: $model.target)
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
			if model.canStop {
				Label("Searching...", systemImage: "hourglass.and.lock")
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
