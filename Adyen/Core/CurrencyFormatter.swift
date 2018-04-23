//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Convenience class to format a payment amount for display.
public final class AmountFormatter {
    
    // MARK: - Public
    
    /// Formats a string based on the provided amount and currency code.
    ///
    /// - Parameters:
    ///   - amount: Amount in minor units, i.e. 2000.
    ///   - currencyCode: The currency code, i.e. "USD".
    /// - Returns: A formatted string, i.e. "$20.00".
    public static func formatted(amount: Int, currencyCode: String) -> String? {
        let decimalAmount = AmountFormatter.decimalAmount(amount, currencyCode: currencyCode)
        return defaultFormatter(currencyCode: currencyCode).string(from: decimalAmount)
    }
    
    // MARK: - Internal
    
    internal static func decimalAmount(_ amount: Int, currencyCode: String) -> NSDecimalNumber {
        let defaultFormatter = AmountFormatter.defaultFormatter(currencyCode: currencyCode)
        let maximumFractionDigits = AmountFormatter.maximumFractionDigits(for: currencyCode)
        defaultFormatter.maximumFractionDigits = maximumFractionDigits
        
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        let convertedAmount = decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits)).doubleValue
        return NSDecimalNumber(value: convertedAmount)
    }
    
    // MARK: - Private
    
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
        case "ISK", "CLP":
            // iOS returns 0, which is in accordance with ISO-4217, but conflicts with our backend.
            // TODO: remove this override once backend is fixed.
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
