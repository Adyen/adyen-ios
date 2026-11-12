//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension CheckoutEncryptor {

    /// An error thrown by ``CheckoutEncryptor``.
    public struct Error: Swift.Error, LocalizedError {

        /// Identifies the kind of error. Compare against the constants in ``CheckoutEncryptor/Error/Code``.
        public let code: Code

        /// A human-readable description of the error.
        public let message: String?

        /// The underlying error that triggered this error, if any.
        public let underlyingError: Swift.Error?

        public var errorDescription: String? {
            message
        }

        internal init(code: Code, message: String?, underlyingError: Swift.Error? = nil) {
            self.code = code
            self.message = message
            self.underlyingError = underlyingError
        }
    }
}

public extension CheckoutEncryptor.Error {

    /// An open-ended error code type backed by a raw string value.
    struct Code: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// The card has no number, security code, expiry month or expiry year to encrypt.
        public static let invalidCard = Code(rawValue: "InvalidCard")
        /// The public key does not have the format `Exponent|Modulus`, or it cannot be parsed.
        public static let invalidPublicKey = Code(rawValue: "InvalidPublicKey")
        /// The encryption failed for another reason.
        public static let encryptionFailed = Code(rawValue: "EncryptionFailed")
    }
}
