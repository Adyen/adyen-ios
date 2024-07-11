//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// UPI  payment method.
public struct UPIPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String

    /// The available UPI apps.
    public let apps: [Issuer]?

    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case apps
    }

}
