//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's expiration date.
/// The input is expected to be sanitized as "MMYY".
/// Validation will fail when the format is invalid or the date is in the past.
@_spi(AdyenInternal)
public final class CardExpiryDateValidator: StatusValidator {
    
    private enum Constants {
        static let maxYearsDifference = 30
        static let firstMonth = 1
        static let lastMonth = 12
        static let minMonthDifference = -3
        static let twentiethCenturyPrefix = "20"
    }
    
    private let referenceDate: Date
    
    private static let maxYearsDifference: Int = 30
    
    public init() {
        self.referenceDate = Date()
    }
    
    internal init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate
    }
    
    public func validate(_ value: String) -> ValidationStatus {
        guard !value.isEmpty else {
            return .invalid(CardValidationError.expiryDateEmpty)
        }
        
        guard value.count == maximumLength(for: value) else {
            return .invalid(CardValidationError.expiryDatePartial)
        }
        
        guard let month = Int(value.adyen[0...1]) else {
            return .invalid(CardValidationError.expiryDatePartial)
        }
        
        guard let year = Int(Constants.twentiethCenturyPrefix + value.adyen[2...3]) else {
            return .invalid(CardValidationError.expiryDatePartial)
        }
        
        guard (month >= Constants.firstMonth && month <= Constants.lastMonth) || value.count < 2 else {
            return .invalid(CardValidationError.expiryDatePartial)
        }
        
        guard let expiryDate = calculateExpiryDate(fromYear: year, month: month) else {
            return .invalid(CardValidationError.expiryDatePartial)
        }
        
        let diffComponents = calendar.dateComponents([.month, .year], from: referenceDate, to: expiryDate)
        
        let monthDiff = diffComponents.month ?? 0
        let yearDiff = diffComponents.year ?? 0
        
        guard yearDiff >= 0 else {
            return .invalid(CardValidationError.cardExpired)
        }
        
        guard yearDiff <= Self.maxYearsDifference else {
            return .invalid(CardValidationError.expiryDateTooFar)
        }
        
        guard monthDiff > Constants.minMonthDifference else {
            return .invalid(CardValidationError.cardExpired)
        }
        
        return .valid
    }
    
    public func isValid(_ string: String) -> Bool {
        validate(string).isValid
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
    
    public func maximumLength(for value: String) -> Int {
        4
    }
    
}
