extension Duration {
	
	/// Construct a `Duration` given a number of minutes represented as a
	/// `BinaryInteger`.
	///
	///       let d: Duration = .minutes(5)
	///
	/// - Returns: A `Duration` representing a given number of minutes.
	@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
	public static func minutes<T>(_ minutes: T) -> Duration where T : BinaryInteger {
		Self.seconds(minutes * 60)
	}
	
	/// Construct a `Duration` given a number of hours represented as a
	/// `BinaryInteger`.
	///
	///       let d: Duration = .hours(2)
	///
	/// - Returns: A `Duration` representing a given number of hours.
	@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
	public static func hours<T>(_ hours: T) -> Duration where T : BinaryInteger {
		Self.minutes(hours * 60)
	}
}
