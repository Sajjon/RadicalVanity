//
//  ContentView.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import SwiftUI
import RadicalVanity


@Observable
public final class Model {
	public var target = "xrd"
	public var secondsElapsed = 0
	private var task: Task<Vanity, Error>?
	public var isShowingSearchHasRunLongTimeWarning = false
	public init() {}
}

// MARK: Public
extension Model {
	
	public var searchHasRunLongTime: Bool {
		secondsElapsed >= 60 * 5 /* 5min */
	}
	
	public func start(force: Bool = false) {
		if !force && warnLongRunSearchInProgressIfNeeded() {
			return
		}
		self.secondsElapsed = 0
		self.task?.cancel()
		self.task = Task {
			while true {
				try await Task.sleep(for: .seconds(1))
				print("secondsElapsed", self.secondsElapsed)
				self.secondsElapsed += 1
			}
		}
	}
	
	public func stop() {
		guard !warnLongRunSearchInProgressIfNeeded() else {
			return
		}
		task?.cancel()
		task = nil
	}
	
	/// Returns `true` if a long running task is running
	@discardableResult private func warnLongRunSearchInProgressIfNeeded() -> Bool {
		guard searchHasRunLongTime else { return false }
		isShowingSearchHasRunLongTimeWarning = true
		return true
	}
		
	public func replaceCurrentSearch() {
		dismissSearchHasRunLongTimeWarning()
		start(force: true)
	}
	
	public func dismissSearchHasRunLongTimeWarning() {
		isShowingSearchHasRunLongTimeWarning = false
	}
	
	public var canSearch: Bool {
		!target.isEmpty && target.count <= 6
	}
	public var canStop: Bool {
		task != nil
	}
}

struct ContentView: View {
	@State var model = Model()
    var body: some View {
        VStack {
			if model.canStop {
				Text("Searching for: '\(model.target)'")
				ProgressView("Elapsed: \(model.secondsElapsed)")
			}
			TextField("Target", text: $model.target)
			Button("Find") {
				model.start(force: false)
			}
			.disabled(!model.canSearch)
			Button("Stop") {
				model.stop()
			}
			.disabled(!model.canStop)
        }
		.confirmationDialog(
			"Apa",
			isPresented: $model.isShowingSearchHasRunLongTimeWarning,
			actions: {
				VStack {
					Button("Replace current search") {
						model.replaceCurrentSearch()
					}
					Button("Wait for current search to finish") {
						model.dismissSearchHasRunLongTimeWarning()
					}
				}
			},
			message: { Text("Hej") }
		)
        .padding()
    }
}

#Preview {
    ContentView()
}
