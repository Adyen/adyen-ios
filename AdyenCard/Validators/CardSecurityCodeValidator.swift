//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Validates a card's security code.
public final class CardSecurityCodeValidator: NumericStringValidator, Observer {
    
    /// Initiate new instance of CardSecurityCodeValidator
    public init() {
        super.init(minimumLength: 3, maximumLength: 4)
    }
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: Observable of a card type
    public init(publisher: AdyenObservable<CardType?>) {
        super.init(minimumLength: 3, maximumLength: 4)
        
        updateExpectedLength(from: publisher.wrappedValue)
        
        observe(publisher) { [weak self] cardType in
            self?.updateExpectedLength(from: cardType)
        }
    }
    
    private func updateExpectedLength(from cardType: CardType?) {
        let length = cardType == .americanExpress ? 4 : 3
        maximumLength = length
        minimumLength = length
    }
    
}
