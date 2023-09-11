//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Helper class to format money amounts and to convert between money amounts in major currency units and amounts in minor currency units.
/// :nodoc:
public final class AmountFormatter {
    
    private init() {}
    
    /// Format money amounts.
    ///
    /// - Parameters:
    ///   - amount: The amount in minor units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale. If nil, device's current locale is used.
    /// - Returns: The formatted text formatted as currency amount.
    public static func formatted(amount: Int, currencyCode: String, localeIdentifier: String? = nil) -> String? {
        let decimalAmount = AmountFormatter.decimalAmount(amount, currencyCode: currencyCode, localeIdentifier: localeIdentifier)
        let formatter = defaultFormatter(currencyCode: currencyCode, localeIdentifier: localeIdentifier)
        return formatter.string(from: decimalAmount)
    }
    
    /// Converts an amount in major currency unit to an amount in minor currency units.
    ///
    /// - Parameters:
    ///   - majorUnitAmount: The amount in major currency units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale. If nil, device's current locale is used.
    public static func minorUnitAmount(from majorUnitAmount: Double, currencyCode: String, localeIdentifier: String? = nil) -> Int {
        let maximumFractionDigits = defaultFormatter(currencyCode: currencyCode, localeIdentifier: localeIdentifier).maximumFractionDigits
        
        return Int(majorUnitAmount * pow(Double(10), Double(maximumFractionDigits)))
    }
    
    /// Converts an amount in major currency unit to an amount in minor currency units.
    ///
    /// - Parameters:
    ///   - majorUnitAmount: The amount in major currency units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale. If nil, device's current locale is used.
    public static func minorUnitAmount(from majorUnitAmount: Decimal, currencyCode: String, localeIdentifier: String? = nil) -> Int {
        let maximumFractionDigits = defaultFormatter(currencyCode: currencyCode, localeIdentifier: localeIdentifier).maximumFractionDigits
        
        let roundTowardsZero = NSDecimalNumberHandler(roundingMode: majorUnitAmount.isSignMinus ? .up : .down,
                                                      scale: 0,
                                                      raiseOnExactness: false,
                                                      raiseOnOverflow: false,
                                                      raiseOnUnderflow: false,
                                                      raiseOnDivideByZero: false)
        
        return (majorUnitAmount as NSDecimalNumber)
            .multiplying(byPowerOf10: Int16(maximumFractionDigits))
            .rounding(accordingToBehavior: roundTowardsZero).intValue
    }
    
    /// Converts an amount in minor currency unit to a decimal amount in major currency units.
    ///
    /// - Parameters:
    ///   - amount: The amount in minor currency units.
    ///   - currencyCode: The code of the currency.
    ///   - localeIdentifier: The identifier of the locale. If nil, device's current locale is used.
    public static func decimalAmount(_ amount: Int, currencyCode: String, localeIdentifier: String? = nil) -> NSDecimalNumber {
        let maximumFractionDigits = defaultFormatter(currencyCode: currencyCode, localeIdentifier: localeIdentifier).maximumFractionDigits
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        return decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits))
    }
    
    private static func defaultFormatter(currencyCode: String, localeIdentifier: String?) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        if let localeIdentifier {
            formatter.locale = Locale(identifier: localeIdentifier)
        }
        if let maxDigits = maximumFractionDigits(for: currencyCode, localeIdentifier: localeIdentifier) {
            formatter.maximumFractionDigits = maxDigits
        }
        return formatter
    }
    
    private static func maximumFractionDigits(for currencyCode: String, localeIdentifier: String?) -> Int? {
        // For some currency codes iOS returns the wrong number of minor units.
        // The below overrides are obtained from https://en.wikipedia.org/wiki/ISO_4217
        
        switch currencyCode {
        case "ISK", "CLP", "COP", "MRU", "RSD", "GHS":
            // iOS returns 0, which is in accordance with ISO-4217, but conflicts with the Adyen backend.
            return 2
        case "CVE", "IDR":
            // iOS returns 2 instead.
            return 0
        default:
            return nil
        }
    }

}
