//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension String {
    
    // MARK: - Getting Substrings
    
    subscript(position: Int) -> String {
        guard position >= 0 && position < count else { return "" }
        
        return String(self[index(startIndex, offsetBy: position)])
    }
    
    subscript(range: Range<Int>) -> String {
        let lowerBound = index(startIndex, offsetBy: range.lowerBound)
        let upperBound = index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
        
        return String(self[lowerBound..<upperBound])
    }
    
    subscript(range: ClosedRange<Int>) -> String {
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
    func grouped(length: Int, separator: String = " ") -> String {
        let groups = stride(from: 0, to: count, by: length).map { index -> String in
            let startIndex = self.index(self.startIndex, offsetBy: index)
            
            let offset = min(length, self.distance(from: startIndex, to: self.endIndex))
            let endIndex = self.index(startIndex, offsetBy: offset)
            
            return String(self[startIndex..<endIndex])
        }
        
        return groups.joined(separator: separator)
    }
    
}
