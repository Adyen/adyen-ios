//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class GiroPayPlugin: Plugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
}

extension GiroPayPlugin: PaymentDetailsPlugin {
    
    internal var canSkipPaymentMethodSelection: Bool {
        return true
    }
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .push
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let controller = GiroPayFormViewController(appearance: appearance, paymentMethod: paymentMethod, paymentSession: paymentSession)
        
        controller.completion = { bic in
            var filledDetails = details
            filledDetails.giroPayBic?.value = bic
            completion(filledDetails)
        }
        
        return controller
    }
    
}
