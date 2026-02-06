//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum CheckoutComponentType: Hashable {
    case payment(PaymentMethodType)
    case action(ActionComponentType)
    
    package init(paymentMethodType: PaymentMethodType) {
        self = .payment(paymentMethodType)
    }
    
    package init(actionType: ActionComponentType) {
        self = .action(actionType)
    }
}

package enum ActionComponentType: Hashable {
    // Contains only action types that require public configuration.
    // Add more cases if their configs need to be public.
    
    case threeDS2
    case twint
}
