//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import AdyenNetworking
import Foundation

/// Describes the methods a delegate of ``AdyenSession`` needs to implement.
public protocol AdyenSessionDelegate: AnyObject {
    
    /// Invoked when the component finishes without any further steps needed by the application.
    /// The application only needs to dismiss the component.
    ///
    /// - Parameters:
    ///   - resultCode: The result code of the completed payment.
    ///   - component: The component object.
    ///   - session: The session object.
    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession)
    
    /// Invoked when a payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The component that failed.
    ///   - session: The session object.
    func didFail(with error: Error, from component: Component, session: AdyenSession)
    
    /// Invoked when the action component opens a third party application outside the scope of the Adyen checkout,
    /// e.g WeChat Pay Application.
    /// In which case you can, for example, stop any loading animations.
    ///
    /// - Parameters:
    ///   - component: The current component object.
    ///   - session: The session object.
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession)
    
    /// Returns a handler for handling the payment data submitted by the shopper that is required for the payments call.
    /// This method is optional.
    /// - Parameters:
    ///   - component: The current payment component object.
    ///   - session: The session object.
    /// - Returns: An instance conforming to the ``AdyenSessionPaymentsHandler``
    /// protocol to take over, or nil to let ``AdyenSession`` handle the flow.
    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler?
    
    /// Returns a handler for handling the additional data provided that is required for the payment details call.
    /// This method is optional.
    /// - Parameters:
    ///   - component: The current action component object.
    ///   - session: The session object.
    /// - Returns: An instance conforming to the ``AdyenSessionPaymentDetailsHandler``
    /// protocol to take over, or nil to let ``AdyenSession`` handle the flow.
    func handlerForAdditionalDetails(in component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler?
}

/// Provides default empty implementation for ``AdyenSessionDelegate``
public extension AdyenSessionDelegate {

    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler? { nil }
    
    func handlerForAdditionalDetails(in component: ActionComponent, session: AdyenSession) -> AdyenSessionPaymentDetailsHandler? { nil }
    
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}
}

/// Describes the interface to take over the step where data is provided for the payments call.
public protocol AdyenSessionPaymentsHandler {
    
    /// Invoked when the shopper submits the data needed for the payments call.
    ///
    /// - Parameters:
    ///   - paymentComponentData: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    ///   - dropInComponent: The DropIn Component instance if any.
    ///   - session: The ``AdyenSession`` instance.
    func didSubmit(_ paymentComponentData: PaymentComponentData,
                   from component: Component,
                   dropInComponent: AnyDropInComponent?,
                   session: AdyenSession)
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

/// Represents the result of a payment via ``AdyenSession``.
public enum SessionPaymentResultCode: String {
    /// Indicates the payment was successfully authorised.
    case authorised = "Authorised"
    
    /// Indicates the payment was refused.
    case refused = "Refused"
    
    /// Indicates that it is not possible to obtain the final status of the payment.
    case pending = "Pending"
    
    /// Indicates the payment has been cancelled
    /// (either by the shopper or the merchant) before processing was completed.
    case cancelled = "Cancelled"
    
    /// There was an error when the payment was being processed.
    case error = "Error"
    
    /// Indicates the payment has successfully been received by Adyen, and will be processed.
    case received = "Received"
    
    /// Indicates that the response contains additional information that is presented to the shopper.
    case presentToShopper = "PresentToShopper"
    
    // Internal init to map payment response to only the final codes.
    internal init(paymentResultCode: PaymentsResponse.ResultCode) {
        switch paymentResultCode {
        case .authenticationFinished,
             .authenticationNotRequired,
             .redirectShopper,
             .identifyShopper,
             .challengeShopper:
            self = .error
        case .presentToShopper:
            self = .presentToShopper
        case .authorised:
            self = .authorised
        case .refused:
            self = .refused
        case .pending:
            self = .pending
        case .cancelled:
            self = .cancelled
        case .error:
            self = .error
        case .received:
            self = .received
        }
    }
}
