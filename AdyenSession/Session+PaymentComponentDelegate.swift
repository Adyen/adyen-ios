//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation
import UIKit

@_spi(AdyenInternal)
extension Session: PaymentComponentDelegate {
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        didSubmit(data, from: component, dropInComponent: nil)
    }
    
    public func didFail(with error: Error, from component: PaymentComponent) {
        failWithError(error, component)
    }
    
    @MainActor
    internal func finish(with result: CheckoutResult, component: Component) {
        let success = result.resultCode == .authorised
            || result.resultCode == .received
            || result.resultCode == .pending
        component.finalizeIfNeeded(with: success) { [weak self] in
            guard let self else { return }
            self.delegate?.didComplete(with: result, component: component, session: self)
        }
    }
    
    @MainActor
    internal func finish(with error: Error, component: Component) {
        failWithError(error, component)
    }
    
    @MainActor
    internal func didFail(with error: Error, currentComponent: Component) {
        failWithError(error, currentComponent)
    }

    @MainActor
    internal func failWithError(_ error: Error, _ component: Component) {
        component.finalizeIfNeeded(with: false) { [weak self] in
            guard let self else { return }
            self.delegate?.didFail(with: error, from: component, session: self)
        }
    }
}

extension Session {
    
    @MainActor
    package func didSubmit(
        _ paymentComponentData: PaymentComponentData,
        from component: PaymentComponent,
        dropInComponent: AnyDropInComponent?
    ) {
        let request = PaymentsRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            data: paymentComponentData
        )
        Task { [weak self] in
            guard let self else { return }
            let submitResult: SubmitResult
            do {
                let response: PaymentsResponse = try await apiClient.performAsync(request)
                submitResult = mapToSubmitResult(response)
            } catch {
                submitResult = .error(error)
            }
            handle(submitResult: submitResult, for: component, in: dropInComponent)
        }
    }

    @MainActor
    private func handle(
        submitResult: SubmitResult,
        for currentComponent: Component,
        in dropInComponent: AnyDropInComponent?
    ) {
        switch submitResult {
        case let .action(action):
            handle(action: action, for: currentComponent, in: dropInComponent)
            
        case let .partialPayment(payload):
            guard let dropInComponent else {
                finish(
                    with: PartialPaymentError.notSupportedForComponent,
                    component: currentComponent
                )
                return
            }
            // ⚠️ BEHAVIOR REGRESSION R1 (v6, intentional — Android parity).
            // Pre-v6 Session showed a "Payment refused" UIAlertController here whenever the
            // `/payments` response had `resultCode == .refused` and a non-zero
            // `order.remainingAmount` (e.g. gift card declined mid-flow). That alert is now
            // removed to match Android's `SessionInteractor`, which routes the same condition
            // (`RefusedPartialPayment`) through its `onFinished(...)` callback without
            // showing UI.
            //
            // Shoppers no longer receive a Session-level "Payment refused" notification on
            // gift-card decline; the drop-in simply reloads with updated payment methods.
            // If UX wants the alert back, it should live in the drop-in layer (not Session).
            updateDropIn(
                dropInComponent,
                with: payload.order,
                currentComponent: currentComponent
            )
            
        case let .finished(resultCode):
            let result = CheckoutResult(
                resultCode: CheckoutResultCode(rawValue: resultCode),
                sessionResult: state.sessionResult
            )
            finish(with: result, component: currentComponent)
            
        case let .error(error):
            finish(with: error, component: currentComponent)
            
        @unknown default:
            AdyenAssertion.assertionFailure(
                message: "Unhandled SubmitResult branch in Session; ignored."
            )
        }
    }
    
    /// Pure mapping from a `/payments` response to a `SubmitResult`.
    /// The mapper is intentionally pure; HTTP / merchant errors are folded at the Task catch site.
    /// `paymentMethodsUpdate` is emitted as `nil` — it is produced later by the session reload and
    /// read by consumers from `state.paymentMethods` at that point.
    internal func mapToSubmitResult(_ response: PaymentsResponse) -> SubmitResult {
        if let action = response.action {
            return .action(action)
        }
        if let order = response.order,
           let remainingAmount = order.remainingAmount,
           remainingAmount.value > 0 {
            return .partialPayment(PartialPayment(order: order, paymentMethodsUpdate: nil))
        }
        return .finished(resultCode: response.resultCode.rawValue)
    }
    
    @MainActor
    private func handle(
        action: Action,
        for currentComponent: Component,
        in dropInComponent: AnyDropInComponent?
    ) {
        if let dropInComponent = dropInComponent as? ActionHandlingComponent {
            dropInComponent.handle(action)
        } else {
            actionHandlingComponent.handle(action)
        }
    }
    
    @MainActor
    private func updateDropIn(_ dropInComponent: AnyDropInComponent, with order: PartialPaymentOrder, currentComponent: Component) {
        let initialInfo = SessionResponse(
            id: state.identifier,
            sessionData: state.data
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                let newState = try await Self.makeSetupCall(
                    with: initialInfo,
                    baseAPIClient: apiClient,
                    order: order
                )
                
                // Update state and reload
                state = newState
                reload(
                    dropInComponent: dropInComponent,
                    with: order,
                    currentComponent: currentComponent
                )
            } catch {
                finish(with: error, component: currentComponent)
            }
        }
    }
    
    @MainActor
    private func reload(
        dropInComponent: AnyDropInComponent,
        with order: PartialPaymentOrder,
        currentComponent: Component
    ) {
        do {
            try dropInComponent.reload(with: order, state.paymentMethods)
        } catch {
            finish(with: error, component: currentComponent)
        }
    }
}
