//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Formats a card's number for display.
public final class CardNumberFormatter: NumericFormatter {
    
    /// The type of card to consider during the formatting.
    /// For example, setting this to `americanExpress` will change the number grouping accordingly.
    public var cardType: CardType?
    
    /// :nodoc:
    override public func formattedValue(for value: String) -> String {
        let sanitizedCardNumber = sanitizedValue(for: value)
        let formattedCardNumberComponents = sanitizedCardNumber.adyen.components(withLengths: cardFormatGrouping)
        return formattedCardNumberComponents.joined(separator: " ")
    }
    
    // MARK: - Private
    
    private let maxCharactersInCardNumber = 19
    
    private var cardFormatGrouping: [Int] {
        if let cardType = cardType, cardType == .americanExpress {
            return [4, 6, 5]
        }
        
        return [4, 4, 4, 4, 4]
    }
}
