//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class Currency {
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    class func formatted(amount: Int, currency code: String) -> String? {
        let formatter = Currency.currencyFormatter
        formatter.currencyCode = code
        
        let maximumFractionDigits = formatter.maximumFractionDigits
        let decimalMinorAmount = NSDecimalNumber(value: amount)
        let convertedAmount = decimalMinorAmount.multiplying(byPowerOf10: Int16(-maximumFractionDigits)).doubleValue
        
        let number = NSNumber(value: convertedAmount)
        
        return formatter.string(from: number)
    }
}
