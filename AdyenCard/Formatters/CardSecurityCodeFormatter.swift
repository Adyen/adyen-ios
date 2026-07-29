//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Formats a card's security code (CVC/CVV).
public final class CardSecurityCodeFormatter: NumericFormatter {
    
    /// Indicate is validating CVV belong to a Amex card
    private var cardBrand: CardBrand?
    private var expectedLength: Int {
        cardBrand == CardBrand.americanExpress ? 4 : 3
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    override public init() {
        super.init()
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: observer of a card type.
    public init(publisher: AdyenObservable<CardBrand?>) {
        super.init()
        bind(publisher, to: self, at: \.cardBrand)
    }
    
    /// Initiate new instance of CardSecurityCodeValidator with a fixed ``CardBrand``
    /// - Parameter cardBrand: The card brand to format the security code for
    public init(cardBrand: CardBrand) {
        super.init()
        self.cardBrand = cardBrand
    }
    
    override public func formattedValue(for value: String) -> String {
        sanitizedValue(for: value)
    }
    
    override public func sanitizedValue(for value: String) -> String {
        let value = super.sanitizedValue(for: value)
        
        if value.count > expectedLength {
            return String(value.prefix(expectedLength))
        }
        
        return value
    }
    
}

@_spi(AdyenInternal)
extension CardSecurityCodeFormatter: AdyenObserver {}
