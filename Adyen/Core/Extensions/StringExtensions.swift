//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension String {
    func boolValue() -> Bool? {
        switch lowercased() {
        case "true":
            return true
        case "false":
            return false
        default:
            return nil
        }
    }
    
    subscript(position: Int) -> String {
        guard position >= 0 && position < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: position)])
    }
    
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) ?? endIndex
        let lowerBound = range.lowerBound < 0 ? 0 : range.lowerBound
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) ?? endIndex
        let lowerBound = range.lowerBound < 0 ? 0 : range.lowerBound
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
    
    /// Separates the string into groups of the given length.
    ///
    /// - Parameters:
    ///   - length: The maximum length of the groups the string should be separated in.
    ///   - separator: The separator to use inbetween the groups.
    /// - Returns: A grouped string.
    internal func grouped(length: Int, separator: String = " ") -> String {
        let groups = stride(from: 0, to: characters.count, by: length).map { index -> String in
            let startIndex = self.index(self.startIndex, offsetBy: index)
            
            let offset = min(length, self.distance(from: startIndex, to: self.endIndex))
            let endIndex = self.index(startIndex, offsetBy: offset)
            
            return self.substring(with: startIndex..<endIndex)
        }
        
        return groups.joined(separator: " ")
    }
    
}
