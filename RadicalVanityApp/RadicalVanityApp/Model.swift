//
//  ContentView.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import SwiftUI
import RadicalVanity
import IdentifiedCollections

@Observable
public final class Model {
	public var results: IdentifiedArrayOf<SearchResult> = []
	public var target = "xrd"
	public var error: String?
	public var duration: Duration = .zero
	private var task: Task<Void, Error>?
	public var isShowingSearchHasRunLongTimeWarning = false
	public var isShowingAreYouSureWannaClearResultsWarning = false
	public init() {}
}

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

// MARK: Public
extension Model {
	
	public var newResults: IdentifiedArrayOf<SearchResult> {
		results.filter(\.isNew)
	}
	
	public var searchHasRunLongTime: Bool {
		duration >= .minutes(20)
	}
	
	public func start(force: Bool = false) {
		if !force && warnLongRunSearchInProgressIfNeeded() {
			return
		}
		self.duration = .zero
		self.task?.cancel()
		self.task = Task {
			let start = ContinuousClock.now
			let suffix = target
			await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						try await Task.sleep(for: .seconds(1))
						self.duration = start.duration(to: .now)
					}
				}
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						let result = try findMnemonicFor(suffix: suffix)
						self.results.append(.init(result: result))
					}
				}
			}
			
		}
	}
	
	public func stop(force: Bool = true) {
		if !force && warnLongRunSearchInProgressIfNeeded() {
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
		guard !target.isEmpty && target.count <= 6 else { return false }
		do {
			try validate(suffix: target)
			self.error = nil
			return true
		} catch {
			self.error = String(describing: error)
			return false
		}
	}
	public var canStop: Bool {
		task != nil
	}
	
	public func clearResults() {
		isShowingAreYouSureWannaClearResultsWarning = true
	}
	public func doClearResults() {
		results = []
	}
	public func markAllAsSeen() {
		results.ids.forEach {
			markSeen(id: $0)
		}
	}
	public func markSeen(id: SearchResult.ID) {
		results[id: id]?.isNew = false
	}
}
