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
    
    /// The preferred way of presenting this component.
    var preferredPresentationMode: PresentableComponentPresentationMode { get }
    
    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    ///   - completion: Completion block to be called when animations are finished.
    func stopLoading(withSuccess success: Bool, completion: (() -> Void)?)
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
    var preferredPresentationMode: PresentableComponentPresentationMode {
        return .push
    }
    
    /// Stops any processing animation that the view controller is running.
    func stopLoading() {
        stopLoading(withSuccess: true, completion: nil)
    }
    
    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    func stopLoading(withSuccess success: Bool) {
        stopLoading(withSuccess: success, completion: nil)
    }
    
    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    ///   - completion: Completion block to be called when animations are finished.
    func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
}

/// Indicates the way a presentable component should be presented.
public enum PresentableComponentPresentationMode {
    
    /// Indicates the component should be pushed onto a navigation stack.
    case push
    
    /// Indicates the component should be presented modally.
    case present
    
}

private struct AssociatedKeys {
    internal static var payment = "paymentObject"
}
