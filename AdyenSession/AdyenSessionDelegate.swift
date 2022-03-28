//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import AdyenNetworking
import Foundation

/// Describes the methods a delegate of `AdyenSession` needs to implement.
public protocol AdyenSessionDelegate: AnyObject {
    
    /// Invoked when the component finishes without any further steps needed by the application.
    /// The application only needs to dismiss the component.
    ///
    /// - Parameters:
    ///   - component: The component object.
    ///   - session: The session object.
    func didComplete(from component: Component, session: AdyenSession)
    
    /// Invoked when a payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The component that failed.
    ///   - session: The session object.
    func didFail(with error: Error, from component: Component, session: AdyenSession)
    
    /// Returns a handler for handling the payment data submitted by the shopper, that is required for the payments call.
    /// - Parameters:
    ///   - component: The current payment component object.
    ///   - session: The session object.
    /// - Returns: An instance conforming to the `SessionComponentPaymentsHandler`.
    /// protocol to take over, or nil to let `AdyenSession` handle it.
    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler?
    
    /// Returns a handler for handling the additional data provided, that is required for the payment details call.
    /// - Parameters:
    ///   - component: The current action component object.
    ///   - session: The session object.
    /// - Returns: An instance conforming to the `SessionComponentPaymentDetailsHandler`.
    /// protocol to take over, or nil to let `AdyenSession` handle it.
    func handlerForAdditionalDetails(in component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler?
}

/// :nodoc:
public extension AdyenSessionDelegate {

    func handlerForPayments(for component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler? { nil }
    
    func handlerForAdditionalDetails(for component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler? { nil }
}

/// Describes the interface to take over the step where data is provided for the payments call.
public protocol AdyenSessionPaymentsHandler {
    
    /// Invoked when the shopper submits the data needed for the payments call.
    ///
    /// - Parameters:
    ///   - paymentComponentData: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    func didSubmit(_ paymentComponentData: PaymentComponentData, from component: Component, session: AdyenSession)
}

/// Describes the interface to take over the step where additional data is provided for making the payment details call.
public protocol AdyenSessionPaymentDetailsHandler {
    
    /// Invoked when there is new data provided that is required for the payment details call.
    ///
    /// - Parameters:
    ///   - actionComponentData: The data supplied by the action component.
    ///   - component: The component that handled the action.
    func didProvide(_ actionComponentData: ActionComponentData, from component: ActionComponent, session: AdyenSession)
}
