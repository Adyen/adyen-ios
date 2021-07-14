//
//  AffirmDetails.swift
//  AdyenComponents
//
//  Created by Naufal Aros on 7/13/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import Foundation

/// Contains the details supplied by the Affirm component.
public struct AffirmDetails: PaymentMethodDetails, ShopperInformation {
    
    /// The payment method type.
    public let type: String
    
    /// The shopper's first and last name.
    public let shopperName: ShopperName
    
    /// The shopper's telephone number.
    public let telephoneNumber: String
    
    /// The shopper's email adress.
    public let emailAddress: String
    
    /// The shopper's billing address.
    public let billingAddress: PostalAddress
    
    /// The shopper's delivery address.
    public let deliveryAddress: PostalAddress?
    
    /// Initializes the Affirm details.
    /// - Parameters:
    ///   - paymentMethod: Affirm payment method.
    ///   - shopperName: The shopper's name.
    ///   - telephoneNumber: The shopper's telephone number.
    ///   - emailAddress: The shopper's email address.
    ///   - billingAddress: The shopper's billing address.
    ///   - deliveryAddress: The shopper's delivery address.
    public init(paymentMethod: PaymentMethod,
                shopperName: ShopperName,
                telephoneNumber: String,
                emailAddress: String,
                billingAddress: PostalAddress,
                deliveryAddress: PostalAddress?) {
        self.type = paymentMethod.type
        self.shopperName = shopperName
        self.telephoneNumber = telephoneNumber
        self.emailAddress = emailAddress
        self.billingAddress = billingAddress
        self.deliveryAddress = deliveryAddress
    }
    
    // MARK: - Private
    
    private enum CodingKeys: CodingKey {
        case type
    }
}
