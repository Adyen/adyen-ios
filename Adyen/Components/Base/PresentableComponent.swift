//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a view controller for the shopper to fill payment details.
public protocol PresentableComponent: Component {
    
    /// The payment information.
    var payment: Payment? { get set }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    var viewController: UIViewController { get }
    
    /// Stops any processing animation that the view controller is running.
    func stopLoading()
}

public extension PresentableComponent {
    
    /// :nodoc:
    var payment: Payment? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.payment) as? Payment
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.payment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// :nodoc:
    func stopLoading() {}
    
}

private struct AssociatedKeys {
    internal static var payment = "paymentObject"
}
