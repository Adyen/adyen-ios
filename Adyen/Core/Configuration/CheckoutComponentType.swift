//
// Copyright (c) Adyen N.V.
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
