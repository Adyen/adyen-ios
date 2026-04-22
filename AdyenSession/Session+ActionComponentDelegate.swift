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

@_spi(AdyenInternal)
extension Session: ActionComponentDelegate {
    public func didFail(with error: Error, from component: ActionComponent) {
        failWithError(error, component)
    }

    public func didComplete(from component: ActionComponent) {
        didComplete(currentComponent: component)
    }
    
    @MainActor
    internal func didComplete(currentComponent: Component) {
        guard let resultCode = state.resultCode else {
            AdyenAssertion.assertionFailure(message: "Missing resultCode.")
            return
        }
        let result = CheckoutResult(
            resultCode: resultCode,
            sessionResult: state.sessionResult
        )
        delegate?.didComplete(with: result, component: currentComponent, session: self)
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        didProvide(data, from: component, dropInComponent: nil)
    }
    
    public func didOpenExternalApplication(component: ActionComponent) {
        didOpenExternalApplication(actionComponent: component)
    }
    
    @MainActor
    internal func didOpenExternalApplication(actionComponent: ActionComponent) {
        delegate?.didOpenExternalApplication(component: actionComponent, session: self)
    }
}

extension Session {
    
    @MainActor
    package func didProvide(
        _ actionComponentData: ActionComponentData,
        from component: ActionComponent,
        dropInComponent: AnyDropInComponent?
    ) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        
        let request = PaymentDetailsRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            paymentData: actionComponentData.paymentData,
            details: actionComponentData.details
        )
        Task { [weak self] in
            guard let self else { return }
            let additionalDetailsResult: AdditionalDetailsResult
            do {
                let response: PaymentsResponse = try await apiClient.performAsync(request)
                additionalDetailsResult = mapToAdditionalDetailsResult(response)
            } catch {
                additionalDetailsResult = .error(error)
            }
            handle(additionalDetailsResult: additionalDetailsResult, for: component)
        }
    }
    
    /// Routes an `AdditionalDetailsResult` to the appropriate Session internal helper.
    ///
    /// The enum does not carry `CheckoutResultCode` or `sessionResult`; those are read from
    /// `state`, which `SessionAPIClient` updates automatically on every response before the
    /// mapper runs (see `SessionResultAware`).
    @MainActor
    private func handle(
        additionalDetailsResult: AdditionalDetailsResult,
        for currentComponent: Component
    ) {
        switch additionalDetailsResult {
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
                message: "Unhandled AdditionalDetailsResult branch in Session; ignored."
            )
        }
    }
    
    /// Pure mapping from a `/payments/details` response to an `AdditionalDetailsResult`.
    ///
    /// Only `.finished(resultCode:)` is produced. The simplified details stage has no `.action`
    /// or `.partialPayment` branches (see plan Open Question #3 — the action-after-details loop
    /// is intentionally removed on v6). HTTP errors are folded at the Task catch site.
    ///
    /// ⚠️ BEHAVIOR REGRESSION safeguard (v6, Behavioral Regression R2):
    /// Pre-v6 Session would recursively trigger action handling when a `/payments/details`
    /// response carried an `action`. v6 drops that path by design, but to keep QA loud about
    /// any backend flow that still emits an action on `/payments/details`, we hit an
    /// `assertionFailure` in debug so the silent drop is visible. Release builds still map
    /// to `.finished(...)` — the action is dropped as the plan specifies.
    internal func mapToAdditionalDetailsResult(_ response: PaymentsResponse) -> AdditionalDetailsResult {
        if response.action != nil {
            AdyenAssertion.assertionFailure(
                message: "Unexpected action on /payments/details response; v6 drops this branch. " +
                    "See Behavioral Regression R2 in IOS_ADVANCED_FLOW_CALLBACK_ALIGNMENT_PLAN_2026-04-16.md."
            )
        }
        return .finished(resultCode: response.resultCode.rawValue)
    }
}
