//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Contains the details supplied by the PayTo component.
public struct PayToDetails: PaymentMethodDetails, ShopperInformation {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The identifier value from the selected payment option.
    public let accountIdentifier: String
    
    /// Name of the shopper.
    public let shopperName: ShopperName?
    
    init(
        paymentMethod: PaymentMethod,
        accountIdentifier: String,
        shopperName: ShopperName?
    ) {
        self.type = paymentMethod.type
        self.accountIdentifier = accountIdentifier
        self.shopperName = shopperName
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case accountIdentifier = "shopperAccountIdentifier"
    }
}
