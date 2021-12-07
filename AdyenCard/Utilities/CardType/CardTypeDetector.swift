//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// So that any `Array` instance will inherit the `adyen` scope.
/// :nodoc:
extension Array: AdyenCompatible {}

/// Adds helper functionality to any `[CardType]` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base == [CardType] {
    
    /// Detects the type for a given card number.
    /// The card type detections are always estimations, as a card type
    /// can never be detected with 100% accuracy on the client side.
    ///
    /// - Parameter cardNumber: The card number to retrieve the type of. The number is expected to be sanitized (digits only).
    /// - Returns: The type for the given card number, or `nil` if it could not be found.
    func types(forCardNumber cardNumber: String) -> [CardType] {
        base.filter { $0.matches(cardNumber: cardNumber) }
    }
    
    /// Detects all possible types for a given card number.
    /// The card type detections are always estimations, as a card type
    /// can never be detected with 100% accuracy on the client side.
    ///
    /// - Parameter cardNumber: The card number to retrieve the types for. The number is expected to be sanitized (digits only).
    /// - Returns: The possible types for the given card number.
    func type(forCardNumber cardNumber: String) -> CardType? {
        base.first { $0.matches(cardNumber: cardNumber) }
    }
}

extension Array where Element: Hashable {

    internal func minus(_ set: Set<Element>) -> [Element] {
        filter { !set.contains($0) }
    }
}
