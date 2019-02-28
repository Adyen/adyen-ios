//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A plugin that presents payment details for the shopper to fill.
/// :nodoc:
public protocol PaymentDetailsPlugin: Plugin {
    
    /// A boolean value indicating whether the payment method selection can be skipped when the payment method is the only one available.
    var canSkipPaymentMethodSelection: Bool { get }
    
    /// A boolean value indicating whether a disclosure indicator should be shown when the payment method is displayed in a list.
    var showsDisclosureIndicator: Bool { get }
    
    /// The preferred presentation mode of view controllers provided by this plugin.
    var preferredPresentationMode: PaymentDetailsPluginPresentationMode { get }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    ///
    /// - Parameters:
    ///   - details: The details that should be filled by the shopper.
    ///   - appearance: The appearance which should be used to style the presented UI.
    ///   - completion: The completion to invoke when the details are filled.
    /// - Returns: A view controller that presents the payment details for the shopper to fill.
    func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController
    
    /// Finishes the presentation of the payment details when a payment has been completed.
    /// This provides an opportunity to show a success/failure state in the UI after submitting the payment.
    ///
    /// - Parameters:
    ///   - result: The result of the finished payment.
    ///   - completion: The completion to invoke when the presentation has been finished.
    func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void)
    
}

/// The presentation mode of a view controller provided by a payment details plugin.
/// :nodoc:
public enum PaymentDetailsPluginPresentationMode {
    
    /// Indicates the view controller should be pushed on top of a navigation controller's stack.
    case push
    
    /// Indicates the view controller should be presented modally.
    case present
    
}

public extension PaymentDetailsPlugin {
    
    /// :nodoc:
    var canSkipPaymentMethodSelection: Bool {
        return false
    }
    
    /// :nodoc:
    var showsDisclosureIndicator: Bool {
        return preferredPresentationMode == .push
    }
    
    /// :nodoc:
    func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void) {
        completion()
    }
    
}
