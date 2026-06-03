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

    /// List of networks enabled on CA.
    public let brands: [String]?
    
    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brands
    }
    
}

// MARK: - PaymentComponentBuildable

extension ApplePayPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
