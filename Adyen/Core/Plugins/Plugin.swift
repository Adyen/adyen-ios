//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances conforming to the Plugin protocol provide native logic for payment methods.
/// :nodoc:
open class Plugin: NSObject {

    // MARK: - Internal
    
    public required init(paymentMethod: PaymentMethod, paymentSession: PaymentSession, appearance: Appearance) {
        self.paymentMethod = paymentMethod
        self.paymentSession = paymentSession
        self.appearance = appearance
    }
    
    open let paymentMethod: PaymentMethod
    open let paymentSession: PaymentSession
    open let appearance: Appearance
    
    open var showsDisclosureIndicator: Bool {
        return false
    }
    
    open var isDeviceSupported: Bool {
        return true
    }
    
    open func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
    }
    
    open func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void) {
        completion()
    }
    
}
