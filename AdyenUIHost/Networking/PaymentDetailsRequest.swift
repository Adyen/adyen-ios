//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import Adyen

internal struct PaymentDetailsRequest: Request {
    
    internal typealias ResponseType = PaymentsResponse
    
    internal let path = "payments/details"
    
    internal let details: AdditionalDetails
    
    internal let paymentData: String
    
    internal var counter: Int = 0
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(details.encodable, forKey: .details)
        try container.encode(paymentData, forKey: .paymentData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case details
        case paymentData
    }
}
