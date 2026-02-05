//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Contains the details supplied by the MB Way component.
public struct MBWayDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The telephone number.
    public let telephoneNumber: String
    
    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?
    
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
        case sdkData
    }
    
}
