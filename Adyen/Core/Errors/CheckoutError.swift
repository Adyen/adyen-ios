//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A standardized error type representing failures within the Adyen Checkout SDK.
public struct CheckoutError: Error, LocalizedError {

    /// Identifies the kind of error. Compare against the constants in ``CheckoutError/Code``.
    public let code: Code

    /// A human-readable description of the error.
    public let message: String?

    /// The underlying error that triggered this error, if any.
    public let underlyingError: Error?

    public var errorDescription: String? {
        message
    }

    public init(code: Code, message: String?, underlyingError: Error? = nil) {
        self.code = code
        self.message = message
        self.underlyingError = underlyingError
    }
}

public extension CheckoutError {

    /// An open-ended error code type backed by a raw string value.
    ///
    /// SDK-defined codes are available as static properties.
    /// You can also create custom codes: `CheckoutError.Code(rawValue: "MyCode")`.
    struct Code: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// The provided client key is malformed or invalid.
        public static let invalidClientKey = Code(rawValue: "InvalidClientKey")
        /// The specified locale is not supported or malformed.
        public static let invalidLocale = Code(rawValue: "InvalidLocale")
        /// The currency code does not conform to ISO 4217.
        public static let invalidCurrencyCode = Code(rawValue: "InvalidCurrencyCode")
        /// The payment amount value is invalid (e.g. negative).
        public static let invalidAmountValue = Code(rawValue: "InvalidAmountValue")
        /// Failed to establish a checkout session.
        public static let sessionSetupFailure = Code(rawValue: "SessionSetupFailure")
        /// The user cancelled the payment.
        public static let cancelled = Code(rawValue: "Cancelled")
        /// An unknown or unexpected error occurred.
        public static let unknown = Code(rawValue: "Unknown")
    }
}
