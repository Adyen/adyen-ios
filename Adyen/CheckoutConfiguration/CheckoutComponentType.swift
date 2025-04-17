//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public enum CheckoutComponentType: Hashable {
    case payment(PaymentMethodType)
    // case action(Action)
    
    init(paymentMethodType: PaymentMethodType) {
        self = .payment(paymentMethodType)
    }
    
    // init(action: Action...
}

@_spi(AdyenInternal)
public class ConfigurationWrapper {
    
    public let configuration: CheckoutComponentConfiguration
    
    public let apiContext: APIContext
    
    public let amount: Amount
    
    public init(
        configuration: CheckoutComponentConfiguration,
        apiContext: APIContext,
        amount: Amount
    ) {
        self.configuration = configuration
        self.apiContext = apiContext
        self.amount = amount
    }
}
