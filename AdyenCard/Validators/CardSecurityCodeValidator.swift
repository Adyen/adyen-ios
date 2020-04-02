//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's security code.
public final class CardSecurityCodeValidator: NumericStringValidator, Observer {
    
    /// Initiate new instance of CardSecurityCodeValidator
    /// - Parameter publisher: Observable of a card type
    public init(publisher: Observable<CardType?>? = nil) {
        super.init(minimumLength: 3, maximumLength: 4)
        guard let publisher = publisher else { return }
        
        updateExpectedLength(from: publisher.value)
        
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
