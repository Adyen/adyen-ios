//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal extension CardEncryptor.Card {
    func encryptedNumber(publicKey: String, date: Date) -> String? { // swiftlint:disable:this explicit_acl
        return ObjC_CardEncryptor.encryptedNumber(number, publicKey: publicKey, date: date)
    }
    
    func encryptedSecurityCode(publicKey: String, date: Date) -> String? { // swiftlint:disable:this explicit_acl
        return ObjC_CardEncryptor.encryptedSecurityCode(securityCode, publicKey: publicKey, date: date)
    }
    
    func encryptedExpiryMoth(publicKey: String, date: Date) -> String? { // swiftlint:disable:this explicit_acl
        return ObjC_CardEncryptor.encryptedExpiryMonth(expiryMonth, publicKey: publicKey, date: date)
    }
    
    func encryptedExpiryYear(publicKey: String, date: Date) -> String? { // swiftlint:disable:this explicit_acl
        return ObjC_CardEncryptor.encryptedExpiryYear(expiryYear, publicKey: publicKey, date: date)
    }
    
    func encryptedToToken(publicKey: String, holderName: String?) -> String? { // swiftlint:disable:this explicit_acl
        return ObjC_CardEncryptor.encryptedToToken(withNumber: number,
                                                   securityCode: securityCode,
                                                   expiryMonth: expiryMonth,
                                                   expiryYear: expiryYear,
                                                   holderName: holderName,
                                                   publicKey: publicKey)
    }
}
