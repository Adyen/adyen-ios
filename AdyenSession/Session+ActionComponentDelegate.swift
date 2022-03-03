//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

extension Session: ActionComponentDelegate {
    public func didFail(with error: Error, from component: ActionComponent) {
        // TODO: call back the merchant
    }

    public func didComplete(from component: ActionComponent) {
        // TODO: call back the merchant
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        // TODO: Make the payment/details call
    }
    
    public func didOpenExternalApplication(_ component: ActionComponent) {
        // TODO: call back the merchant
    }
}
