//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension CheckoutEncryptor {

    /// A field that ``CheckoutEncryptor/encrypt(field:value:publicKey:)`` can encrypt.
    public struct Field: Hashable {

        /// The key of the value in the encrypted payload.
        internal let key: String

        private init(key: String) {
            self.key = key
        }

        /// The card number. Send the result as `encryptedCardNumber`.
        public static let cardNumber = Field(key: "number")

        /// The card security code. Send the result as `encryptedSecurityCode`.
        public static let securityCode = Field(key: "cvc")

        /// The card expiry month. Send the result as `encryptedExpiryMonth`.
        public static let expiryMonth = Field(key: "expiryMonth")

        /// The card expiry year. Send the result as `encryptedExpiryYear`.
        public static let expiryYear = Field(key: "expiryYear")

        /// The first 2 digits of the card password, for Korean cards (KCP). Send the result as `encryptedPassword`.
        public static let kcpPassword = Field(key: "password")

        /// The bank account number. Send the result as `encryptedBankAccountNumber`.
        public static let bankAccountNumber = Field(key: "bankAccountNumber")

        /// The bank routing number. Send the result as `encryptedBankLocationId`.
        public static let bankRoutingNumber = Field(key: "bankLocationId")

        /// The BIN of a card number, for the BIN lookup.
        package static let bin = Field(key: "binValue")
    }
}
