//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Contains the details supplied by the Atome component.
public struct AtomeDetails: PaymentMethodDetails, ShopperInformation {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The shopper's first and last name.
    public let shopperName: ShopperName?
    
    /// The shopper's telephone number.
    public let telephoneNumber: String?
    
    /// The shopper's billing address.
    public let billingAddress: PostalAddress?

    /// Initializes the Atome details.
    /// - Parameters:
    ///   - paymentMethod: Atome payment method.
    ///   - shopperName: The shopper's name.
    ///   - telephoneNumber: The shopper's telephone number.
    ///   - billingAddress: The shopper's billing address.
    public init(paymentMethod: PaymentMethod,
                shopperName: ShopperName,
                telephoneNumber: String,
                billingAddress: PostalAddress) {
        self.type = paymentMethod.type
        self.shopperName = shopperName
        self.telephoneNumber = telephoneNumber
        self.billingAddress = billingAddress
    }
    
    // MARK: - Private
    
    private enum CodingKeys: CodingKey {
        case type
    }
}
