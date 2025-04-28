//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum CheckoutComponentType: Hashable {
    case payment(PaymentMethodType)
    // case action(Action)
    
    package init(paymentMethodType: PaymentMethodType) {
        self = .payment(paymentMethodType)
    }
    
    // init(action: Action...
}

/// A wrapper to hold a configuration along with other necessary properties a
/// configuration does not have access to such as apiContext/amount etc.
package class ConfigurationWrapper {
    
    package let configuration: CheckoutComponentConfiguration
    
    package let apiContext: APIContext
    
    package let amount: Amount
    
    package init(
        configuration: CheckoutComponentConfiguration,
        apiContext: APIContext,
        amount: Amount
    ) {
        self.configuration = configuration
        self.apiContext = apiContext
        self.amount = amount
    }
}
