//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum CheckoutConfigurationType: Hashable {
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
    case threeDS2
    case twint
    case redirect
    case await
        case qrCode
    case voucher
    case document
}
