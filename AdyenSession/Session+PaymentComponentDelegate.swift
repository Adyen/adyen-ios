//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension Session: PaymentComponentDelegate {
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        // TODO: Make the payment call
    }

    public func didFail(with error: Error, from component: PaymentComponent) {
        // TODO: call back the merchant
    }
}
