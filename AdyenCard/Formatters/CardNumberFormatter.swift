//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Formats a card's number for display.
public final class CardNumberFormatter: NumericFormatter {
    
    /// The type of card to consider during the formatting.
    /// For example, setting this to `americanExpress` will change the number grouping accordingly.
    public var cardType: CardType?
    
    /// :nodoc:
    public override func formattedValue(for value: String) -> String {
        let sanitizedCardNumber = sanitizedValue(for: value)
        let formattedCardNumberComponents = sanitizedCardNumber.components(withLengths: cardFormatGrouping)
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
