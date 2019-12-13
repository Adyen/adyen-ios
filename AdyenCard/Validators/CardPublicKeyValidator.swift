//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's public key.
internal struct CardPublicKeyValidator: Validator {
    
    /// :nodoc:
    public func isValid(_ string: String) -> Bool {
        guard let range = string.range(of: #"([0-9]){5}\|([A-Z]|[0-9]){512}"#, options: .regularExpression) else {
            return false
        }
        return range == (string.startIndex..<string.endIndex)
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int {
        return 518
    }
}
