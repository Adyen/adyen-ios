//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
extension String: AdyenCompatible {

    /// :nodoc:
    public enum Adyen {

        /// :nodoc:
        public static let securedString: String = "••••\u{00a0}"
    }
}

/// :nodoc:
extension Optional: AdyenCompatible {}

/// :nodoc:
public extension AdyenScope where Base == String? {

    /// Returns true if optional string is null or not empty.
    var isNullOrEmpty: Bool {
        base == nil || base?.isEmpty == false
    }
    
    /// Returns nil string is empty or actual value.
    var nilIfEmpty: String? {
        guard let base else { return nil }
        return base.isEmpty ? nil : base
    }

}

/// :nodoc:
public extension AdyenScope where Base == String {

    /// Return flag emoji if string is a country code; otherwise returns empty string.
    var countryFlag: String? {
        guard CountryCodeValidator().isValid(base) else { return nil }
        let baseIndex = 127397
        let unicodeScalarValue = base.utf16
            .compactMap { UnicodeScalar(baseIndex + Int($0)) }
            .reduce(into: String.UnicodeScalarView()) { result, scalar in result.append(scalar) }
        return String(unicodeScalarValue)
    }

    /// Returns nil string is empty or actual value.
    var nilIfEmpty: String? {
        base.isEmpty ? nil : base
    }
    
    /// Truncate the string to the specified length.
    ///
    /// - Parameters:
    ///   - length: The maximum desired length for the string.
    /// - Returns: A truncated string.
    func truncate(to length: Int) -> String {
        (base.count > length) ? String(base.prefix(length)) : base
    }
    
    /// Separates a string into substrings of the given lengths.
    ///
    /// - Parameter lengths: The lengths to separate the string into.
    /// - Returns: An array of substring with the given lengths.
    func components(withLengths lengths: [Int]) -> [String] {
        guard !base.isEmpty else { return [] }
        
        var input = base
        var output = [String]()
        
        for length in lengths {
            let substring = input.removeAndReturnFirst(length)
            output.append(substring)
            
            if input.isEmpty {
                break
            }
        }
        
        return output
    }
    
    /// Separates a string into substrings of the given length.
    ///
    /// - Parameter length: The length of each of the substrings.
    /// - Returns: An array of substrings of the given length.
    func components(withLength length: Int) -> [String] {
        var input = base
        var output = [String]()
        
        while !input.isEmpty {
            let substring = input.removeAndReturnFirst(length)
            output.append(substring)
        }
        
        return output
    }
    
    /// Get the substring at a given position.
    ///
    /// - Parameter position: The position of the desired substring.
    /// - Returns: A string with the substring of the given position.
    subscript(position: Int) -> String {
        guard position >= 0, position < base.count else { return "" }
        
        return String(base[base.index(base.startIndex, offsetBy: position)])
    }
    
    /// Get the substring from a given open range.
    /// If the range does not overlap with the base string at all, returns an empty string.
    ///
    /// - Parameter range: The range of the desired substring.
    /// - Returns: A string with the substring of the given range.
    subscript(range: Range<Int>) -> String {
        guard let safe = safeRange(from: range) else { return "" }
        return String(base[safe])
    }
    
    /// Get the substring from a given closed range.
    /// If the range does not overlap with the base string at all, returns an empty string.
    ///
    /// - Parameter range: The closed range of the desired substring.
    /// - Returns: A string with the substring of the given closed range.
    subscript(range: ClosedRange<Int>) -> String {
        guard let safeRange = safeClosedRange(from: range) else { return "" }
        return String(base[safeRange])
    }
    
    /// Returns an open range from the given range that is within the `base`'s bounds, to prevent out of bounds access.
    /// - Parameter range: The desired range to access in the `base`.
    /// - Returns: A new open range that is within the `base`'s bounds, or nil when there is no overlap.
    internal func safeRange(from range: Range<Int>) -> Range<String.Index>? {
        guard !base.isEmpty else { return nil }
        let baseRange = 0..<base.count
        guard baseRange.overlaps(range) else { return nil }
        let clampedRange = baseRange.clamped(to: range)
        
        let lowerIndex = base.index(base.startIndex, offsetBy: clampedRange.lowerBound)
        let upperIndex = base.index(lowerIndex, offsetBy: clampedRange.upperBound - clampedRange.lowerBound)
        
        return lowerIndex..<upperIndex
    }
    
    /// Returns a closed range from the given range that is within the `base`'s bounds, to prevent out of bounds access.
    /// - Parameter range: The desired range to access in the `base`.
    /// - Returns: A new closed range that is within the `base'`s bounds, or nil when there is no overlap.
    internal func safeClosedRange(from range: ClosedRange<Int>) -> ClosedRange<String.Index>? {
        guard !base.isEmpty else { return nil }
        let baseRange = 0...base.count - 1
        guard baseRange.overlaps(range) else { return nil }
        let clampedRange = baseRange.clamped(to: range)
        
        let lowerIndex = base.index(base.startIndex, offsetBy: clampedRange.lowerBound)
        let upperIndex = base.index(lowerIndex, offsetBy: clampedRange.upperBound - clampedRange.lowerBound)
        
        return lowerIndex...upperIndex
    }
}

extension String {
    
    // MARK: - Private
    
    fileprivate mutating func removeAndReturnFirst(_ length: Int) -> String {
        let end = index(startIndex, offsetBy: length, limitedBy: endIndex) ?? endIndex
        
        let substring = self[startIndex..<end]
        removeSubrange(self.startIndex..<end)
        
        return String(substring)
    }
    
}
