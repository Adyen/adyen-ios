//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// So that any `Array` instance will inherit the `adyen` scope.
@_spi(AdyenInternal)
extension Array: AdyenCompatible {}

// Adds helper functionality to any `[CardBrand]` instance through the `adyen` property.

package extension AdyenScope where Base == [CardBrand] {
    
    /// Detects all possible brands for a given card number.
    /// The card brand detections are always estimations, as a card brand
    /// can never be detected with 100% accuracy on the client side.
    ///
    /// - Parameter cardNumber: The card number to retrieve the brands of. The number is expected to be sanitized (digits only).
    /// - Returns: The possible brands for the given card number.
    func types(forCardNumber cardNumber: String) -> [CardBrand] {
        base.filter { $0.matches(cardNumber: cardNumber) }
    }
    
    /// Detects the brand for a given card number.
    /// The card brand detections are always estimations, as a card brand
    /// can never be detected with 100% accuracy on the client side.
    ///
    /// - Parameter cardNumber: The card number to retrieve the brand of. The number is expected to be sanitized (digits only).
    /// - Returns: The brand for the given card number, or `nil` if it could not be found.
    func type(forCardNumber cardNumber: String) -> CardBrand? {
        base.first { $0.matches(cardNumber: cardNumber) }
    }
}

extension Array where Element: Hashable {

    internal func minus(_ set: Set<Element>) -> [Element] {
        filter { !set.contains($0) }
    }
}
