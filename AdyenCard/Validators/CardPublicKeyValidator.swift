//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Validates a card's public key.
internal struct CardPublicKeyValidator: Validator {
    
    /// :nodoc:
    public func isValid(_ string: String) -> Bool {
        guard let range = string.range(of: #"([0-9A-F]){5}\|([A-F]|[0-9]){512}"#, options: .regularExpression) else {
            return false
        }
        return range == (string.startIndex..<string.endIndex)
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        518
    }
}
