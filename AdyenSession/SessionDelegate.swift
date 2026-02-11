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

/// Describes the methods a delegate of ``Session`` needs to implement.
public protocol SessionDelegate: AnyObject {
    
    /// Invoked when the component finishes without any further steps needed by the application.
    /// The application only needs to dismiss the component.
    ///
    /// - Parameters:
    ///   - result: The result object of the completed payment.
    ///   - component: The component object.
    ///   - session: The session object.
    func didComplete(with result: CheckoutResult, component: Component, session: Session)
    
    /// Invoked when a payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The component that failed.
    ///   - session: The session object.
    func didFail(with error: Error, from component: Component, session: Session)
    
    /// Invoked when the action component opens a third party application outside the scope of the Adyen checkout,
    /// e.g WeChat Pay Application.
    /// In which case you can, for example, stop any loading animations.
    ///
    /// - Parameters:
    ///   - component: The current component object.
    ///   - session: The session object.
    func didOpenExternalApplication(component: ActionComponent, session: Session)
}

/// Provides default empty implementation for ``SessionDelegate``
public extension SessionDelegate {
    
    func didOpenExternalApplication(component: ActionComponent, session: Session) {}
}
