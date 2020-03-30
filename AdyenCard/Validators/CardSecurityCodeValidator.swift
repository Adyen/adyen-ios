//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's security code.
internal final class CardSecurityCodeValidator: Validator, Observer {
    
    /// Indicate is validating CVV belong to a Amex card
    private var cardType: CardType?
    private var expectedLength: Int { cardType == CardType.americanExpress ? 4 : 3 }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: observer of a card type
    public init(publisher: Observable<CardType?>? = nil) {
        guard let publisher = publisher else { return }
        
        bind(publisher, to: self, at: \.cardType)
    }
    
    /// :nodoc:
    public func isValid(_ string: String) -> Bool {
        return string.count == expectedLength
    }
    
    /// :nodoc:
    public func maximumLength(for value: String) -> Int { expectedLength }
}
