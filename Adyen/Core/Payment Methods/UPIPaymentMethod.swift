//
// Copyright (c) 2020 Adyen N.V.
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

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case apps
    }

}

// MARK: - PaymentComponentBuildable

extension UPIPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
