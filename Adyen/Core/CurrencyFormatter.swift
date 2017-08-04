//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Convenience class to format a number with a given currency.
internal class CurrencyFormatter {
    
    internal static func format(_ amount: Int, currencyCode: String) -> String? {
        currencyFormatter.currencyCode = currencyCode
        
        let maximumFractionDigits = currencyFormatter.maximumFractionDigits
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        let convertedAmount = decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits)).doubleValue
        
        let number = NSNumber(value: convertedAmount)
        
        return currencyFormatter.string(from: number)
    }
    
    private static let currencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        
        return currencyFormatter
    }()
    
    private init() {
        
    }
    
}
