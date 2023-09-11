//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Collection of the generic personal details supplied by components.
/// :nodoc:
public struct BasicPersonalInfoFormDetails: PaymentMethodDetails, ShopperInformation {

    /// The payment method type.
    public let type: String

    /// The shopper Name.
    public var shopperName: ShopperName? {
        guard let firstName else { return nil }
        guard let lastName else { return nil }
        return ShopperName(firstName: firstName, lastName: lastName)
    }

    /// The first Name.
    public let firstName: String?

    /// The last Name.
    public let lastName: String?

    /// The email address.
    public let emailAddress: String?

    /// The telephone number.
    public let telephoneNumber: String?

    /// Initializes the  generic personal details.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - firstName: The first Name.
    ///   - lastName: The last Name.
    ///   - emailAddress: The email address.
    ///   - telephoneNumber: The email address.
    public init(paymentMethod: PaymentMethod,
                firstName: String,
                lastName: String,
                emailAddress: String,
                telephoneNumber: String) {
        self.type = paymentMethod.type
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.telephoneNumber = telephoneNumber
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

}
