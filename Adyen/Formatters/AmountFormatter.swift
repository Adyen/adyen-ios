//
// Copyright (c) 2021 Adyen N.V.
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
    public static func formatted(amount: Int, currencyCode: String) -> String? {
        let decimalAmount = AmountFormatter.decimalAmount(amount, currencyCode: currencyCode)
        
        return defaultFormatter(currencyCode: currencyCode).string(from: decimalAmount)
    }
    
    /// Converts an amount in major currency unit to an amount in minor currency units.
    ///
    /// - Parameters:
    ///   - majorUnitAmount: The amount in major currency units.
    ///   - currencyCode: The code of the currency.
    public static func minorUnitAmount(from majorUnitAmount: Double, currencyCode: String) -> Int {
        let maximumFractionDigits = AmountFormatter.maximumFractionDigits(for: currencyCode)
        
        return Int(majorUnitAmount * pow(Double(10), Double(maximumFractionDigits)))
    }
    
    /// Converts an amount in major currency unit to an amount in minor currency units.
    ///
    /// - Parameters:
    ///   - majorUnitAmount: The amount in major currency units.
    ///   - currencyCode: The code of the currency.
    public static func minorUnitAmount(from majorUnitAmount: Decimal, currencyCode: String) -> Int {
        let maximumFractionDigits = AmountFormatter.maximumFractionDigits(for: currencyCode)
        
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
    
    private static func decimalAmount(_ amount: Int, currencyCode: String) -> NSDecimalNumber {
        let defaultFormatter = AmountFormatter.defaultFormatter(currencyCode: currencyCode)
        let maximumFractionDigits = AmountFormatter.maximumFractionDigits(for: currencyCode)
        defaultFormatter.maximumFractionDigits = maximumFractionDigits
        
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        let convertedAmount = decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits)).doubleValue
        return NSDecimalNumber(value: convertedAmount)
    }
    
    private static func defaultFormatter(currencyCode: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter
    }
    
    private static func maximumFractionDigits(for currencyCode: String) -> Int {
        // For some currency codes iOS returns the wrong number of minor units.
        // The below overrides are obtained from https://en.wikipedia.org/wiki/ISO_4217
        
        switch currencyCode {
        case "ISK", "CLP", "COP":
            // iOS returns 0, which is in accordance with ISO-4217, but conflicts with the Adyen backend.
            return 2
        case "MRO":
            // iOS returns 0 instead.
            return 1
        case "RSD":
            // iOS returns 0 instead.
            return 2
        case "CVE":
            // iOS returns 2 instead.
            return 0
        case "GHC":
            // iOS returns 2 instead.
            return 0
        default:
            let formatter = defaultFormatter(currencyCode: currencyCode)
            return formatter.maximumFractionDigits
        }
    }
    
}
