//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the Qiwi Wallet component.
public struct QiwiWalletDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// The telephone number prefix.
    public let phonePrefix: String
    
    /// The telephone number.
    public let phoneNumber: String
    
    /// Initializes the Qiwi Wallet details.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethod: The Qiwi Wallet payment method.
    ///   - phonePrefix: The telephone number prefix.
    ///   - phoneNumber: The telephone number.
    public init(paymentMethod: PaymentMethod, phonePrefix: String, phoneNumber: String) {
        self.type = paymentMethod.type
        self.phonePrefix = phonePrefix
        self.phoneNumber = phoneNumber
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case phonePrefix = "qiwiwallet.telephoneNumberPrefix"
        case phoneNumber = "qiwiwallet.telephoneNumber"
    }
    
}
