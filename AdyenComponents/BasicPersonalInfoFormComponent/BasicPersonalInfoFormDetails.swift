//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Collection of the generic personal details supplied by components.
public struct BasicPersonalInfoFormDetails: PaymentMethodDetails, ShopperInformation {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The payment method type.
    public let type: PaymentMethodType

    /// The shopper Name.
    public var shopperName: ShopperName? {
        guard let firstName = firstName else { return nil }
        guard let lastName = lastName else { return nil }
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
