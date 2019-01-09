//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCardInternal

internal extension CardEncryptor.Card {
    func encryptedNumber(publicKey: String, date: Date) -> String? {
        let card = ADYCard()
        card.number = number
        
        return encrypted(card: card, publicKey: publicKey, date: date)
    }
    
    func encryptedSecurityCode(publicKey: String, date: Date) -> String? {
        let card = ADYCard()
        card.cvc = securityCode
        
        return encrypted(card: card, publicKey: publicKey, date: date)
    }
    
    func encryptedExpiryMoth(publicKey: String, date: Date) -> String? {
        let card = ADYCard()
        card.expiryMonth = expiryMonth
        
        return encrypted(card: card, publicKey: publicKey, date: date)
    }
    
    func encryptedExpiryYear(publicKey: String, date: Date) -> String? {
        let card = ADYCard()
        card.expiryYear = expiryYear
        
        return encrypted(card: card, publicKey: publicKey, date: date)
    }
    
    func encryptedToToken(publicKey: String, holderName: String?, date: Date) -> String? {
        let card = ADYCard()
        card.number = number
        card.cvc = securityCode
        card.holderName = holderName
        card.expiryYear = expiryYear
        card.expiryMonth = expiryMonth
        
        return encrypted(card: card, publicKey: publicKey, date: date)
    }
    
    fileprivate func encrypted(card: ADYCard, publicKey: String, date: Date) -> String? {
        card.generationtime = date
        
        if let encoded = card.encode() {
            return ADYEncrypter.encrypt(encoded, publicKeyInHex: publicKey)
        }
        
        return nil
    }
}
