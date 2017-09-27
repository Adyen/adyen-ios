//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension String {
    
    // MARK: - Describing a String
    
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
    
    // MARK: - Getting Substrings
    
    internal subscript(position: Int) -> String {
        guard position >= 0 && position < characters.count else { return "" }
        
        return String(self[index(startIndex, offsetBy: position)])
    }
    
    internal subscript(range: Range<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: range.lowerBound)
        let upperBound = index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(self[lowerBound..<upperBound])
    }
    
    internal subscript(range: ClosedRange<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: range.lowerBound)
        let upperBound = index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(self[lowerBound...upperBound])
    }
    
    // MARK: - Grouping
    
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
            
            return String(self[startIndex..<endIndex])
        }
        
        return groups.joined(separator: " ")
    }
    
}
