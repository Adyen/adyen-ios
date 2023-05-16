//
// Copyright (c) 2023 Adyen N.V.
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
        let grouping = cardFormatGrouping(for: sanitizedCardNumber.count)
        let formattedCardNumberComponents = sanitizedCardNumber.adyen.components(withLengths: grouping)
        return formattedCardNumberComponents.joined(separator: " ")
    }
    
    // MARK: - Private
    
    private let maxCharactersInCardNumber = 19
    
    private func cardFormatGrouping(for length: Int) -> [Int] {
        switch cardType {
        case .americanExpress:
            return [4, 6, 5]
        case .diners where length < 15:
            return [4, 6, 4]
        default:
            return Array(repeating: 4, count: (length / 4) + 1)
        }
    }
}
