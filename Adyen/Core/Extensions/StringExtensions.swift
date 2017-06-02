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
    
    func numberOnly() -> String {
        return replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
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
}
