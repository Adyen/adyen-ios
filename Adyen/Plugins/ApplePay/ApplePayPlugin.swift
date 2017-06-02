//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

let applePayMerchantIdentifierKey = "merchantIdentifier"

class ApplePayPlugin: BasePlugin {
    fileprivate var presenter: ApplePayDetailsPresenter?
}

extension ApplePayPlugin: UIPresentable {
    
    func detailsPresenter() -> PaymentMethodDetailsPresenter? {
        presenter = ApplePayDetailsPresenter()
        return presenter
    }
}

extension ApplePayPlugin: DeviceDependable {
    
    func isDeviceSupported() -> Bool {
        let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
}

extension ApplePayPlugin: RequiresFinalState {
    
    func finishWith(state: PaymentStatus, completion: (() -> Void)?) {
        presenter?.finishWith(state: state)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion?()
        }
    }
}
