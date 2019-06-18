//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Formats a card's security code (CVC/CVV).
public final class CardSecurityCodeFormatter: NumericFormatter {
    
    /// :nodoc:
    public override func formattedValue(for value: String) -> String {
        return sanitizedValue(for: value)
    }
    
    // MARK: - Private
    
    private let maxLength = 4
    
}
