//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Detects the card type for any given card number.
/// The card type detections are always estimations, as a card type
/// can never be detected with 100% accuraccy on the client side.
public final class CardTypeDetector {
    
    /// The types to detect.
    public var detectableTypes: [CardType] = [.visa, .masterCard, .americanExpress]
    
    /// Initializes the card type detector.
    public init() {}
    
    /// Detects the type for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the type of. The number is expected to be sanitized (digits only).
    /// - Returns: The type for the given card number, or `nil` if it could not be found.
    public func type(forCardNumber cardNumber: String) -> CardType? {
        return detectableTypes.first { $0.matches(cardNumber: cardNumber) }
    }
    
    /// Detects all possible types for a given card number.
    ///
    /// - Parameter cardNumber: The card number to retrieve the types for. The number is expected to be sanitized (digits only).
    /// - Returns: The possible types for the given card number.
    public func types(forCardNumber cardNumber: String) -> [CardType] {
        return detectableTypes.filter { $0.matches(cardNumber: cardNumber) }
    }
    
}
