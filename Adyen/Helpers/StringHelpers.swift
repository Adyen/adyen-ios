//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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

}

/// :nodoc:
public extension AdyenScope where Base == String {

    /// Return flag emoji if string is a country code; otherwise returns emty string.
    var countryFlag: String {
        guard CountryCodeValidator().isValid(base) else { return "" }
        let baseIndex = 127397
        var usv = String.UnicodeScalarView()
        base.utf16.compactMap { UnicodeScalar(baseIndex + Int($0)) }.forEach { usv.append($0) }
        return String(usv)
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
    ///
    /// - Parameter range: The range of the desired substring.
    /// - Returns: A string with the substring of the given range.
    subscript(range: Range<Int>) -> String {
        let lowerBound = base.index(base.startIndex, offsetBy: range.lowerBound)
        let upperBound = base.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(base[lowerBound..<upperBound])
    }
    
    /// Get the substring from a given closed range.
    ///
    /// - Parameter range: The closed range of the desired substring.
    /// - Returns: A string with the substring of the given closed range.
    subscript(range: ClosedRange<Int>) -> String {
        let lowerBound = base.index(base.startIndex, offsetBy: range.lowerBound)
        let upperBound = base.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(base[lowerBound...upperBound])
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
