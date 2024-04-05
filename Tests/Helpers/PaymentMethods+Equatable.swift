//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension PaymentMethods: Equatable {
    public static func == (lhs: PaymentMethods, rhs: PaymentMethods) -> Bool {
        guard lhs.regular.count == rhs.regular.count else { return false }
        guard lhs.stored.count == rhs.stored.count else { return false }
        for (paymentMethod1, paymentMethod2) in zip(lhs.regular, rhs.regular) {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        for (paymentMethod1, paymentMethod2) in zip(lhs.stored, rhs.stored) {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        return true
    }
}
