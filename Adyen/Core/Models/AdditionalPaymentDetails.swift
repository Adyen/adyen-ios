//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances conforming to AdditionalPaymentDetails represent additionals details needed to complete a payment.
public protocol AdditionalPaymentDetails {
    
    /// The list of details that need to be filled.
    var details: [PaymentDetail] { get set }
    
    /// A dictionary of arbitrary values used to collect the additional payment details.
    var userInfo: [String: String] { get }
    
}

/// A structure that contains details that are needed to identify the shopper.
public struct IdentificationPaymentDetails: AdditionalPaymentDetails {
    
    /// The list of details that need to be filled.
    public var details: [PaymentDetail]
    
    /// A dictionary of arbitrary values used to collect the additional payment details.
    public var userInfo: [String: String]
    
}

/// A structure that contains the information needed to challenge the shopper.
public struct ChallengePaymentDetails: AdditionalPaymentDetails {
    
    /// The list of details that need to be filled.
    public var details: [PaymentDetail]
    
    /// A dictionary of arbitrary values used to collect the additional payment details.
    public var userInfo: [String: String]
    
}

public extension AdditionalPaymentDetails {
    
    /// The data to be used on the redirect, if needed.
    @available(*, deprecated, renamed: "userInfo")
    var redirectData: [String: String] {
        return userInfo
    }
    
}
