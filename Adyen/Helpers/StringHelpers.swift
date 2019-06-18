//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public extension String {
    
    /// Truncate the string to the specified length.
    ///
    /// - Parameters:
    ///   - length: The maximum desired length for the string.
    /// - Returns: A truncated string.
    func truncate(to length: Int) -> String {
        return (count > length) ? String(prefix(length)) : self
    }
    
    /// Separates a string into substrings of the given lengths.
    ///
    /// - Parameter lengths: The lengths to separate the string into.
    /// - Returns: An array of substring with the given lengths.
    func components(withLengths lengths: [Int]) -> [String] {
        guard isEmpty == false else {
            return []
        }
        
        var input = self
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
        var input = self
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
        guard position >= 0, position < count else { return "" }
        
        return String(self[index(startIndex, offsetBy: position)])
    }
    
    /// Get the substring from a given open range.
    ///
    /// - Parameter range: The range of the desired substring.
    /// - Returns: A string with the substring of the given range.
    subscript(range: Range<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: range.lowerBound)
        let upperBound = index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(self[lowerBound..<upperBound])
    }
    
    /// Get the substring from a given closed range.
    ///
    /// - Parameter range: The closed range of the desired substring.
    /// - Returns: A string with the substring of the given closed range.
    subscript(range: ClosedRange<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: range.lowerBound)
        let upperBound = index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(self[lowerBound...upperBound])
    }
    
    // MARK: - Private
    
    private mutating func removeAndReturnFirst(_ length: Int) -> String {
        let end = index(startIndex, offsetBy: length, limitedBy: endIndex) ?? endIndex
        
        let substring = self[startIndex..<end]
        removeSubrange(startIndex..<end)
        
        return String(substring)
    }
    
}
