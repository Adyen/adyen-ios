//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal extension CardEncryptor.Card {
    func encryptedNumber(publicKey: String, date: Date) throws -> String? { // swiftlint:disable:this explicit_acl
        guard let number = number else { return nil }
        guard let encryptedNumber = ObjC_CardEncryptor.encryptedNumber(number, publicKey: publicKey, date: date) else {
            throw CardEncryptor.Error.encryptionFailed
        }
        return encryptedNumber
    }
    
    func encryptedSecurityCode(publicKey: String, date: Date) throws -> String? { // swiftlint:disable:this explicit_acl
        guard let securityCode = securityCode else { return nil }
        guard let encryptedSecurityCode = ObjC_CardEncryptor.encryptedSecurityCode(securityCode, publicKey: publicKey, date: date) else {
            throw CardEncryptor.Error.encryptionFailed
        }
        return encryptedSecurityCode
    }
    
    func encryptedExpiryMonth(publicKey: String, date: Date) throws -> String? { // swiftlint:disable:this explicit_acl
        guard let expiryMonth = expiryMonth else { return nil }
        guard let encryptedExpiryMonth = ObjC_CardEncryptor.encryptedExpiryMonth(expiryMonth, publicKey: publicKey, date: date) else {
            throw CardEncryptor.Error.encryptionFailed
        }
        return encryptedExpiryMonth
    }
    
    func encryptedExpiryYear(publicKey: String, date: Date) throws -> String? { // swiftlint:disable:this explicit_acl
        guard let expiryYear = expiryYear else { return nil }
        guard let encryptedExpiryYear = ObjC_CardEncryptor.encryptedExpiryYear(expiryYear, publicKey: publicKey, date: date) else {
            throw CardEncryptor.Error.encryptionFailed
        }
        return encryptedExpiryYear
    }
    
    func encryptedToToken(publicKey: String, holderName: String?) throws -> String? { // swiftlint:disable:this explicit_acl
        // Make sure not all the card ivars's are nil, otherwise throw Error.invalidEncryptionArguments
        guard [number, securityCode, expiryMonth, expiryYear, holderName].contains(where: { $0 != nil }) else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        guard let encryptionResult = ObjC_CardEncryptor.encryptedToToken(withNumber: number,
                                                                         securityCode: securityCode,
                                                                         expiryMonth: expiryMonth,
                                                                         expiryYear: expiryYear,
                                                                         holderName: holderName,
                                                                         publicKey: publicKey) else {
            throw CardEncryptor.Error.encryptionFailed
            
        }
        return encryptionResult
    }
}
