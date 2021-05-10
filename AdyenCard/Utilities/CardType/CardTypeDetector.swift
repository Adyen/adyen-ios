//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Detects the card type for any given card number.
/// The card type detections are always estimations, as a card type
/// can never be detected with 100% accuraccy on the client side.
@available(*, deprecated, message: "Use extension for `[CardType] instead")
public final class CardTypeDetector {
    
    /// The types to detect.
    public var detectableTypes: [CardType]
    
    /// Initializes the card type detector.
    public init(detectableTypes: [CardType] = [.visa, .masterCard, .americanExpress]) {
        self.detectableTypes = detectableTypes
    }
    
    /// Detects the type for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the type of. The number is expected to be sanitized (digits only).
    /// - Returns: The type for the given card number, or `nil` if it could not be found.
    @available(*, deprecated, message: "Use extension for `[CardType].adyen.type(forCardNumber:)` instead.")
    public func type(forCardNumber cardNumber: String) -> CardType? {
        detectableTypes.adyen.type(forCardNumber: cardNumber)
    }
    
    /// Detects all possible types for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the types for. The number is expected to be sanitized (digits only).
    /// - Returns: The possible types for the given card number.
    @available(*, deprecated, message: "Use extension for `[CardType].adyen.types(forCardNumber:)` instead.")
    public func types(forCardNumber cardNumber: String) -> [CardType] {
        detectableTypes.adyen.types(forCardNumber: cardNumber)
    }
    
}

/// So that any `Array` instance will inherit the `adyen` scope.
/// :nodoc:
extension Array: AdyenCompatible {}

/// Adds helper functionality to any `[CardType]` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base == [CardType] {
    
    /// Detects the type for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the type of. The number is expected to be sanitized (digits only).
    /// - Returns: The type for the given card number, or `nil` if it could not be found.
    func types(forCardNumber cardNumber: String) -> [CardType] {
        base.filter { $0.matches(cardNumber: cardNumber) }
    }
    
    /// Detects all possible types for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the types for. The number is expected to be sanitized (digits only).
    /// - Returns: The possible types for the given card number.
    func type(forCardNumber cardNumber: String) -> CardType? {
        base.first { $0.matches(cardNumber: cardNumber) }
    }
}
