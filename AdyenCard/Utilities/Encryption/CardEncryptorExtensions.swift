//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

extension CardEncryptor.Card {
    internal func encryptedNumber(publicKey: String, date: Date) throws -> String? {
        var card = CardEncryptor.Card(number: self.number)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedSecurityCode(publicKey: String, date: Date) throws -> String? {
        var card = CardEncryptor.Card(securityCode: self.securityCode)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedExpiryMonth(publicKey: String, date: Date) throws -> String? {
        var card = CardEncryptor.Card(expiryMonth: self.expiryMonth)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedExpiryYear(publicKey: String, date: Date) throws -> String? {
        var card = CardEncryptor.Card(expiryYear: self.expiryYear)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedToToken(publicKey: String, holderName: String?) throws -> String? {
        // Make sure not all the card ivars's are nil, otherwise throw Error.invalidEncryptionArguments
        guard [number, securityCode, expiryMonth, expiryYear, holderName].contains(where: { $0 != nil }) else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        var card = CardEncryptor.Card(number: self.number,
                                      securityCode: self.securityCode,
                                      expiryMonth: self.expiryMonth,
                                      expiryYear: self.expiryYear)
        card.holder = holderName
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    private func encryptCard(publicKey: String, card: CardEncryptor.Card) throws -> String? {
        guard let encodedCard = card.jsonData() else { return nil }
        return ADYCryptor.encrypt(data: encodedCard, publicKey: publicKey)
    }
}
