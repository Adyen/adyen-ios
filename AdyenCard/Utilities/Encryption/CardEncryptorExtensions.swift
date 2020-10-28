//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension CardEncryptor.Card {
    internal func encryptedNumber(publicKey: String, date: Date) throws -> String? {
        guard let number = number else { return nil }
        var card = CardEncryptor.Card(number: number)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedSecurityCode(publicKey: String, date: Date) throws -> String? {
        guard let securityCode = securityCode else { return nil }
        var card = CardEncryptor.Card(securityCode: securityCode)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedExpiryMonth(publicKey: String, date: Date) throws -> String? {
        guard let expiryMonth = expiryMonth else { return nil }
        var card = CardEncryptor.Card(expiryMonth: expiryMonth)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedExpiryYear(publicKey: String, date: Date) throws -> String? {
        guard let expiryYear = expiryYear else { return nil }
        var card = CardEncryptor.Card(expiryYear: expiryYear)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    internal func encryptedToToken(publicKey: String, holderName: String?) throws -> String {
        guard !isEmpty else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        var card = CardEncryptor.Card(number: self.number,
                                      securityCode: self.securityCode,
                                      expiryMonth: self.expiryMonth,
                                      expiryYear: self.expiryYear)
        card.holder = holderName
        return try encryptCard(publicKey: publicKey, card: card)
    }
    
    private func encryptCard(publicKey: String, card: CardEncryptor.Card) throws -> String {
        guard let encodedCard = card.jsonData() else { throw CardEncryptor.Error.invalidEncryptionArguments }

        do {
            return try Cryptor.encrypt(data: encodedCard, publicKey: publicKey)
        } catch {
            throw CardEncryptor.Error.encryptionFailed
        }
    }
}
