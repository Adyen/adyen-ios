//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum AnalyticsConstants {
    
    /// A constant to pass into the payment data object in the case where fetching the checkout attempt Id fails.
    public static let fetchCheckoutAttemptIdFailed = "fetch-checkoutAttemptId-failed"
    
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
