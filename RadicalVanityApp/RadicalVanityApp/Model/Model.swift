//
//  ContentView.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import AVFoundation
import SwiftUI
import RadicalVanity
import IdentifiedCollections

@Observable
public final class Model {
	public var results: IdentifiedArrayOf<SearchResult> = []
	public var target = "eee" // 15 sec ATM
	public var error: String?
	public var duration: Duration = .zero
	var searchTask: SearchTask?
	public var deterministic = false
	public var isShowingSearchHasRunLongTimeWarning = false
	public var isShowingAreYouSureWannaClearResultsWarning = false
	public init() {}
}

@Observable
public final class SearchTask {
	private var task: Task<Void, Error>?
	public let target: String
	
	func cancel() {
		task?.cancel()
	}
	deinit {
		task?.cancel()
	}
	init(
		target: String,
		deterministic: Bool,
		onTick: @escaping @Sendable (Duration) -> Void,
		onResult: @escaping @Sendable (Vanity) -> Void
	) {
		self.target = target
		self.task = Task {
			let start = ContinuousClock.now
			let suffix = target
			await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						try await Task.sleep(for: .seconds(1))
						onTick(start.duration(to: .now))
					}
				}
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						let result = try findMnemonicFor(
							suffix: suffix,
							deterministic: deterministic
						)
						onResult(result)
					}
				}
				
			}
			
		}
	}
}


// MARK: Public
extension Model {
	
	public var newResults: IdentifiedArrayOf<SearchResult> {
		results.filter(\.isNew)
	}
	
	public var resultsForCurrentTarget: IdentifiedArrayOf<SearchResult> {
		guard let searchTask else { return [] }
		return results.filter { $0.result.input.targetSuffix == searchTask.target }
	}
	
	public var searchHasRunLongTime: Bool {
		duration >= .minutes(20)
	}
	
	public func start(force: Bool = false) {
		if !force && warnLongRunSearchInProgressIfNeeded() {
			return
		}
		self.duration = .zero
		self.searchTask?.cancel()
		let playSound = target.count >= 4
		self.searchTask = SearchTask(
			target: target,
			deterministic: deterministic
		) {
			self.duration = $0
		} onResult: {
			if playSound {
				AudioServicesPlaySystemSound(1026)
			}
			self.results.append(.init(result: $0))
		}
	}
	
	public func stop(force: Bool = true) {
		if !force && warnLongRunSearchInProgressIfNeeded() {
			return
		}
		searchTask?.cancel()
		searchTask = nil
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
		searchTask != nil
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
