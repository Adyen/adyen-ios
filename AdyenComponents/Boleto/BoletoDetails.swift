//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the Boleto component.
public struct BoletoDetails: PaymentMethodDetails,
                             ShopperInformation, BillingAddressInformation, SocialSecurityNumberInformation {

    /// The type of the payment method
    public let type: String

    /// The first name and last name of the shopper.
    public let shopperName: ShopperName?

    /// The social security number of the shopper.
    public let socialSecurityNumber: String?

    /// The email address of the shopper.
    public let emailAddress: String?

    /// The billing address of the shopper.
    public let billingAddress: AddressInfo?
    
    /// :nodoc:
    public let telephoneNumber: String? = nil

}
