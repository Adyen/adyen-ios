//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Instances conforming to the Plugin protocol provide native logic for payment methods.
/// :nodoc:
public protocol Plugin: AnyObject {
    
    var paymentSession: PaymentSession { get }
    var paymentMethod: PaymentMethod { get }
    
    init(paymentSession: PaymentSession, paymentMethod: PaymentMethod)
    
    var isDeviceSupported: Bool { get }
    
}

/// :nodoc:
public extension Plugin {
    
    var isDeviceSupported: Bool {
        return true
    }
    
}
