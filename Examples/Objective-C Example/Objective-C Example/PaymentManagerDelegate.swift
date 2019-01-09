//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@objc protocol PaymentManagerDelegate {
    func paymentManager(_ paymentManager: PaymentManager, didFinishWithResult result: PaymentManagerResult)
    
}
