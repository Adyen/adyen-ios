//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the Doku component.
public struct DokuDetails: PaymentMethodDetails {

    /// The payment method type.
    public let type: String

    /// The first Name.
    public let firstName: String

    /// The last Name.
    public let lastName: String

    /// The email address.
    public let emailAddress: String

    /// Initializes the MB Way details.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethod: The Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
    ///   - firstName: The first Name.
    ///   - lastName: The last Name.
    ///   - emailAddress: The email address.
    public init(paymentMethod: PaymentMethod,
                firstName: String,
                lastName: String,
                emailAddress: String) {
        self.type = paymentMethod.type
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case firstName
        case lastName
        case emailAddress = "shopperEmail"
    }

}
