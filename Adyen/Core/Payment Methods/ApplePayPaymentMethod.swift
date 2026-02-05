//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An Apple pay payment method.
public struct ApplePayPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    /// List of networks enabled on CA.
    public let brands: [String]?

    // MARK: - Initializers

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    internal init(
        type: PaymentMethodType,
        name: String,
        merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? = nil,
        brands: [String]?
    ) {
        self.type = type
        self.name = name
        self.merchantProvidedDisplayInformation = merchantProvidedDisplayInformation
        self.brands = brands
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brands
    }
    
}
