//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Object that is aware of a `PaymentMethod`.
package protocol PaymentMethodAware {

    /// The payment method for which to gather payment details.
    var paymentMethod: PaymentMethod { get }
    
}

/// A component that handles stored payment methods.
package protocol StoredPaymentComponent: PaymentComponent, PresentableComponent {}

package enum PaymentComponentType {
    case regular(PaymentComponent & PresentableComponent)
    case stored(StoredPaymentComponent)
    case initiable(PaymentComponent)
}

/// A component that handles the initial phase of getting payment details to initiate a payment.
@MainActor
package protocol PaymentComponent: Component, PartialPaymentOrderAware, PaymentMethodAware {

    /// The delegate of the payment component.
    var delegate: PaymentComponentDelegate? { get set }

    var type: PaymentComponentType { get }

    var paymentMethodBehavior: SDKData.PaymentMethodBehavior { get }

    func performSubmit()
}

package extension PaymentComponent where Self: PresentableComponent {

    var type: PaymentComponentType {
        .regular(self)
    }
}

package extension StoredPaymentComponent {

    var type: PaymentComponentType {
        .stored(self)
    }
}

package extension PaymentComponent {

    var type: PaymentComponentType {
        .initiable(self)
    }
}

extension PaymentComponent {
    
    /// Submits payment data to the payment delegate.
    /// - Parameters:
    ///   - data: The Payment data to be submitted
    ///   - component: The component from which the payment originates.
    package func submit(data: PaymentComponentData, component: PaymentComponent? = nil) {
        Task { [weak self] in
            guard let self else { return }
            sendSubmitEvent()
            let component = component ?? self
            let updatedData = await prepareSubmitData(from: data)
            self.delegate?.didSubmit(updatedData, from: component)
        }
    }
    
    package var checkoutAttemptId: String {
        context.analyticsProvider?.checkoutAttemptId ?? AnalyticsConstants.fetchCheckoutAttemptIdFailed
    }
    
    /// Adds SDK related info to payment data object and returns the final data in the completion.
    package func prepareSubmitData(from data: PaymentComponentData) async -> PaymentComponentData {

        let sdkData = SDKData(
            checkoutAttemptId: checkoutAttemptId,
            paymentMethodBehavior: paymentMethodBehavior,
            authenticationProvider: data.paymentMethod as? SDKDataAuthenticationProvider
        )
        
        return await data
            .replacing(checkoutAttemptId: checkoutAttemptId)
            .replacing(sdkData: sdkData)
            .replacing(browserInfo: BrowserInfo())
    }
    
    private func sendSubmitEvent() {
        let logEvent = AnalyticsEventLog(component: paymentMethod.type.rawValue, type: .submit)
        context.analyticsProvider?.add(log: logEvent)
    }
}

/// Describes the methods a delegate of the payment component needs to implement.
@MainActor
package protocol PaymentComponentDelegate: AnyObject {

    /// Invoked when the shopper submits the data needed for the payments call.
    ///
    /// - Parameters:
    ///   - data: The data supplied by the payment component.
    ///   - component: The payment component from which the payment details were submitted.
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent)
    
    /// Invoked when the payment component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - component: The payment component that failed.
    func didFail(with error: Error, from component: PaymentComponent)
    
}
