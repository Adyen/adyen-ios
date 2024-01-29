//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Formats a card's security code (CVC/CVV).
public final class CardSecurityCodeFormatter: NumericFormatter, Observer {
    
    /// Indicate is validating CVV belong to a Amex card
    private var cardType: CardType?
    private var expectedLength: Int { cardType == CardType.americanExpress ? 4 : 3 }
    
    /// Initiate new instance of CardSecurityCodeValidator
    override public init() {
        super.init()
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: observer of a card type.
    public init(publisher: AdyenObservable<CardType?>) {
        super.init()
        bind(publisher, to: self, at: \.cardType)
    }
    
    /// Initiate new instance of CardSecurityCodeValidator with a fixed ``CardType``
    /// - Parameter cardType: The card type to format the security code for
    public init(cardType: CardType) {
        super.init()
        self.cardType = cardType
    }
    
    /// :nodoc:
    override public func formattedValue(for value: String) -> String {
        let value = super.formattedValue(for: value)
        
        if value.count > expectedLength {
            return String(value.prefix(expectedLength))
        }
        
        return value
    }
    
}
