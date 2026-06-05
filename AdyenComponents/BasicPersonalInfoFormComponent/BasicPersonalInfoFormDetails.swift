//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
@_spi(AdyenInternal) import protocol Adyen.ShopperInformation

/// Collection of the generic personal details supplied by components.
package struct BasicPersonalInfoFormDetails: PaymentMethodDetails, ShopperInformation {

    package var checkoutAttemptId: String?

    /// The payment method type.
    package let type: PaymentMethodType

    /// The shopper Name.
    package var shopperName: ShopperName? {
        guard let firstName else { return nil }
        guard let lastName else { return nil }
        return ShopperName(firstName: firstName, lastName: lastName)
    }

    /// The first Name.
    package let firstName: String?

    /// The last Name.
    package let lastName: String?

    /// The email address.cd
    package let emailAddress: String?

    /// The telephone number.
    package let telephoneNumber: String?

    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    package var sdkData: String?

    /// Initializes the  generic personal details.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - firstName: The first Name.
    ///   - lastName: The last Name.
    ///   - emailAddress: The email address.
    ///   - telephoneNumber: The email address.
    package init(
        paymentMethod: PaymentMethod,
        firstName: String,
        lastName: String,
        emailAddress: String,
        telephoneNumber: String
    ) {
        self.type = paymentMethod.type
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.telephoneNumber = telephoneNumber
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case sdkData
    }

}
