//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum AnalyticsConstants {
    
    /// A constant to pass into the payment data object in the case where fetching the checkout attempt Id fails.
    public static let fetchCheckoutAttemptIdFailed = "fetch-checkoutAttemptId-failed"
    
    /// Struct to hold error codes as type-safe static variables.
    public struct ErrorCode {
        
        public static let redirectFailed = ErrorCode(600)
        public static let redirectParseFailed = ErrorCode(601)
        public static let encryptionError = ErrorCode(610)
        public static let thirdPartyError = ErrorCode(611)
        public static let apiErrorPayments = ErrorCode(620)
        public static let apiErrorDetails = ErrorCode(621)
        public static let apiErrorThreeDS2 = ErrorCode(622)
        public static let apiErrorOrder = ErrorCode(624)
        public static let apiErrorPublicKeyFetch = ErrorCode(625)
        public static let apiErrorNativeRedirect = ErrorCode(626)
        public static let threeDS2PaymentDataMissing = ErrorCode(700)
        public static let threeDS2TokenMissing = ErrorCode(701)
        public static let threeDS2DecodingFailed = ErrorCode(704)
        public static let threeDS2FingerprintCreationFailed = ErrorCode(705)
        public static let threeDS2TransactionCreationFailed = ErrorCode(706)
        public static let threeDS2TransactionMissing = ErrorCode(707)
        public static let threeDS2FingerprintHandlingFailed = ErrorCode(708)
        public static let threeDS2ChallengeHandlingFailed = ErrorCode(709)
        
        public init(_ rawValue: Int) {
            self.rawValue = rawValue
        }
        
        private var rawValue: Int
        
        public var stringValue: String { String(rawValue) }
    }
    
    public enum ValidationErrorCodes {
        
        public static let cardNumberEmpty = 900
        public static let cardNumberPartial = 901
        public static let cardLuhnCheckFailed = 902
        public static let cardUnsupported = 903
        public static let expiryDateEmpty = 910
        public static let expiryDatePartial = 911
        public static let cardExpired = 912
        public static let expiryDateTooFar = 913
        public static let securityCodeEmpty = 920
        public static let securityCodePartial = 921
        public static let holderNameEmpty = 925
        public static let brazilSSNEmpty = 926
        public static let brazilSSNPartial = 927
        public static let postalCodeEmpty = 934
        public static let postalCodePartial = 935
        public static let kcpPasswordEmpty = 940
        public static let kcpPasswordPartial = 941
        public static let kcpFieldEmpty = 942
        public static let kcpFieldPartial = 943
    }
}
