//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A structure representing additionals details needed to complete a payment.
public struct AdditionalPaymentDetails {
    
    /// The list of details that need to be filled.
    public var details: [PaymentDetail]
    
    /// The data to be used on the redirect, if needed.
    public var redirectData: [String: String]
}
