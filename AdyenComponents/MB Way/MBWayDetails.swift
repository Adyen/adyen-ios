//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the MB Way component.
public struct MBWayDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// The telephone number.
    public let telephoneNumber: String
    
    /// Initializes the MB Way details.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethod: The MB Way payment method.
    ///   - telephoneNumber: The telephone number.
    public init(paymentMethod: PaymentMethod, telephoneNumber: String) {
        self.type = paymentMethod.type
        self.telephoneNumber = telephoneNumber
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case telephoneNumber
    }
    
}
