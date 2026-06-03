//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A WeChat Pay payment method.
public struct WeChatPayPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
        
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}

// MARK: - PaymentComponentBuildable

extension WeChatPayPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
