//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal struct PreselectedPaymentMethodManager {
    internal static func preselectedPaymentMethod(for paymentSession: PaymentSession) -> PaymentMethod? {
        return paymentSession.paymentMethods.preferred.first
    }
    
    internal static func saveSelectedPaymentMethod(_ paymentMethod: PaymentMethod) {}
    
}
