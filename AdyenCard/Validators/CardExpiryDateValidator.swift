//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Validates a card's expiration date.
/// The input is expected to be sanitized as "MMYY".
/// Validation will fail when the format is invalid or the date is in the past.
public final class CardExpiryDateValidator: Validator {
    
    private let referenceDate: Date
    
    private static let maxYearsDifference: Int = 30
    
    /// :nodoc:
    public init() {
        self.referenceDate = Date()
    }
    
    /// :nodoc:
    internal init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate
    }
    
    /// :nodoc:
    public func isValid(_ string: String) -> Bool {
        guard string.count == maximumLength(for: string) else { return false }
        
        guard let month = Int(string.adyen[0...1]) else { return false }
        guard let year = Int("20" + string.adyen[2...3]) else { return false }
        
        guard (month >= 1 && month <= 12) || string.count < 2 else { return false }
        guard let expiryDate = calculateExpiryDate(fromYear: year, month: month) else { return false }
        
        let diffComponents = calendar.dateComponents([.month, .year], from: referenceDate, to: expiryDate)
        
        let monthDiff = diffComponents.month ?? 0
        let yearDiff = diffComponents.year ?? 0
        
        guard (0...Self.maxYearsDifference).contains(yearDiff), monthDiff >= -3 else { return false }
        
        return true
    }
    
    private var calendar: Calendar { Calendar(identifier: .gregorian) }
    
    private func calculateExpiryDate(fromYear year: Int, month: Int) -> Date? {
        var expiryDateComponents = DateComponents()
        expiryDateComponents.month = month
        expiryDateComponents.year = year
        expiryDateComponents.day = 1
        guard let beginningOfMonthDate = calendar.date(from: expiryDateComponents) else { return nil }
        guard let beginningNextMonthDate = calendar.date(byAdding: .month, value: 1, to: beginningOfMonthDate) else { return nil }
        guard let endOfMonthDate = calendar.date(byAdding: .day, value: -1, to: beginningNextMonthDate) else { return nil }
        
        return endOfMonthDate
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        4
    }
    
}
