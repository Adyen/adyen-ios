//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Convenience class to format a number with a given currency.
internal class CurrencyFormatter {
    
    // MARK: - Initialization
    
    private init() {
        
    }
    
    // MARK: - Internal
    
    internal static func format(_ amount: Int, currencyCode: String) -> String? {
        currencyFormatter.currencyCode = currencyCode
        
        let maximumFractionDigits = CurrencyFormatter.maximumFractionDigits(for: currencyCode)
        currencyFormatter.maximumFractionDigits = maximumFractionDigits
        
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        let convertedAmount = decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits)).doubleValue
        
        let number = NSNumber(value: convertedAmount)
        
        return currencyFormatter.string(from: number)
    }
    
    // MARK: - Private
    
    private static let currencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        
        return currencyFormatter
    }()
    
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
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = currencyCode
            return currencyFormatter.maximumFractionDigits
        }
    }
    
}
