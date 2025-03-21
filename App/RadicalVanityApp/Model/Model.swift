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

@MainActor
@Observable
public final class Model {
	public var results: IdentifiedArrayOf<SearchResult> = []
	public var targetsString = "aa,00"
	public var error: String?
	public var duration: Duration = .zero
	var searchTask: SearchTask?
	public var deterministic = true
	public var isShowingSearchHasRunLongTimeWarning = false
	public var isShowingAreYouSureWannaClearResultsWarning = false
	public init() {}

	public var targets: [String] {
		splitIntoTargets(commaSeperatedString: targetsString)
	}
}

public struct SearchTask {
	@ObservationIgnored private var task: Task<Void, Error>?
	@ObservationIgnored public let targets: [String]
	public func targetsDescription(charLimit: Int = 13) -> String {
		let joined = targets.joined(separator: ",")
		if joined.count <= charLimit {
			return joined
		}
		return "#\(targets.count)🎯"
	}
	
	func cancel() {
		task?.cancel()
	}
	init(
		targets: [String],
		deterministic: Bool,
		onTick: @escaping @Sendable (Duration) async -> Void,
		onResult: @escaping @Sendable (Vanity) async -> Void
	) {
		self.targets = targets
		self.task = Task {
			let start = ContinuousClock.now
			await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						try await Task.sleep(for: .seconds(1))
						await onTick(start.duration(to: .now))
					}
				}
				_ = group.addTaskUnlessCancelled(priority: .high) {
					while true {
						try Task.checkCancellation()
						try await findMnemonicFor(
							targets: targets,
							deterministic: deterministic,
							onResult: onResult
						)
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
	
	public var resultsForCurrentTargets: IdentifiedArrayOf<SearchResult> {
		guard let searchTask else { return [] }
		return results.filter { r in searchTask.targets.contains(r.result.input.targetSuffix) }
	}
	
	public var searchHasRunLongTime: Bool {
		duration >= .minutes(20)
	}
	public func update(duration: Duration) async {
		self.duration = duration
	}
	public func append(result: Vanity) async {
		self.results.append(.init(result: result))
	}
	public func start(force: Bool = false) {
		var playSound = false
		do {
			for target in targets {
				try validate(suffix: target)
				if target.count > 6 {
					self.error = String(describing: "Cannot search for longer suffix than 6. Will never finish.")
					return
				}
				playSound = playSound || target.count >= 4
			}
			self.error = nil
		} catch {
			self.error = String(describing: error)
			return
		}
		
		if !force && warnLongRunSearchInProgressIfNeeded() {
			return
		}
		self.duration = .zero
		self.searchTask?.cancel()
		let _playSound = playSound
		self.searchTask = SearchTask(
			targets: targets,
			deterministic: deterministic
		) {
			await self.update(duration: $0)
		} onResult: {
			if _playSound {
				AudioServicesPlaySystemSound(1026)
			}
			await self.append(result: $0)
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
