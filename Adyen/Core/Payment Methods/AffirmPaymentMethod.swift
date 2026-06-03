//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Affirm payment method.
public struct AffirmPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}

// MARK: - PaymentComponentBuildable

extension AffirmPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
