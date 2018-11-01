//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A plugin that presents payment details for the shopper to fill.
/// :nodoc:
public protocol PaymentDetailsPlugin: Plugin {
    
    /// A boolean value indicating whether a disclosure indicator should be shown when the payment method is displayed in a list.
    var showsDisclosureIndicator: Bool { get }
    
    /// Presents payment details for the shopper to fill.
    ///
    /// - Parameters:
    ///   - details: The details that should be filled by the shopper.
    ///   - navigationController: The navigation controller which can be used for presenting the details.
    ///   - appearance: The appearance which should be used to style the presented UI.
    ///   - completion: The completion to invoke when the details are filled.
    func present(_ details: [PaymentDetail], using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>)
    
    /// Finishes the presentation of the payment details when a payment has been completed.
    /// This provides an opportunity to show a success/failure state in the UI after submitting the payment.
    ///
    /// - Parameters:
    ///   - result: The result of the finished payment.
    ///   - completion: The completion to invoke when the presentation has been finished.
    func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void)
    
}

public extension PaymentDetailsPlugin {
    
    /// :nodoc:
    public var showsDisclosureIndicator: Bool {
        return false
    }
    
    /// :nodoc:
    public func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void) {
        completion()
    }
    
}
