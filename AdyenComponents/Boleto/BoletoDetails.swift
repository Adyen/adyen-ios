//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the Boleto component.
public struct BoletoDetails: PaymentMethodDetails, ShopperInformation {

    /// The type of the payment method
    public let type: String

    /// The first name and last name of the shopper.
    public let shopperName: ShopperName?

    /// The social security number of the shopper.
    public let socialSecurityNumber: String?

    /// The email address of the shopper.
    public let emailAddress: String?

    /// The billing address of the shopper.
    public let billingAddress: PostalAddress?
    
    /// :nodoc:
    public let telephoneNumber: String? = nil
    
    /// Initializes the Boleto details
    /// - Parameters:
    ///   - type: Boleto payment method.
    ///   - shopperName: Name of the shopper.
    ///   - socialSecurityNumber: CPF/CNPJ of the shopper.
    ///   - emailAddress: Optional email address of the shopper.
    ///   - billingAddress: Billing address of the shopper.
    public init(
        type: String,
        shopperName: ShopperName,
        socialSecurityNumber: String,
        emailAddress: String?,
        billingAddress: PostalAddress
    ) {
        self.type = type
        self.shopperName = shopperName
        self.socialSecurityNumber = socialSecurityNumber
        self.emailAddress = emailAddress
        self.billingAddress = billingAddress
    }
    
    private enum CodingKeys: CodingKey {
        case type
    }
}
