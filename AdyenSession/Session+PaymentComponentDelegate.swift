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
    
    internal func finish(with result: CheckoutResult, component: Component) {
        let success = result.resultCode == .authorised
            || result.resultCode == .received
            || result.resultCode == .pending
        component.finalizeIfNeeded(with: success) { [weak self] in
            guard let self else { return }
            self.delegate?.didComplete(with: result, component: component, session: self)
        }
    }
    
    internal func finish(with error: Error, component: Component) {
        failWithError(error, component)
    }

    public func didFail(with error: Error, from component: PaymentComponent) {
        failWithError(error, component)
    }
    
    internal func didFail(with error: Error, currentComponent: Component) {
        failWithError(error, currentComponent)
    }

    internal func failWithError(_ error: Error, _ component: Component) {
        component.finalizeIfNeeded(with: false) { [weak self] in
            guard let self else { return }
            self.delegate?.didFail(with: error, from: component, session: self)
        }
    }
}

extension Session {
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
        apiClient.perform(request) { [weak self] in
            self?.handle(paymentResponseResult: $0, for: component, in: dropInComponent)
        }
    }
    
    internal func handle(
        paymentResponseResult: Result<PaymentsResponse, Error>,
        for currentComponent: Component,
        in dropInComponent: AnyDropInComponent? = nil
    ) {
        switch paymentResponseResult {
        case let .success(response):
            handle(paymentResponse: response, for: currentComponent, in: dropInComponent)
        case let .failure(error):
            finish(with: error, component: currentComponent)
        }
    }
    
    private func handle(
        paymentResponse response: PaymentsResponse,
        for currentComponent: Component,
        in dropInComponent: AnyDropInComponent?
    ) {
        if let action = response.action {
            handle(action: action, for: currentComponent, in: dropInComponent)
        } else if let order = response.order,
                  let remainingAmount = order.remainingAmount,
                  remainingAmount.value > 0 {
            
            guard let dropInComponent else {
                finish(
                    with: PartialPaymentError.notSupportedForComponent,
                    component: currentComponent
                )
                return
            }
            
            handle(
                order: order,
                resultCode: response.resultCode,
                currentComponent: currentComponent,
                dropInComponent: dropInComponent
            )
            
        } else {
            let result = CheckoutResult(
                resultCode: response.resultCode,
                sessionResult: response.sessionResult
            )
            finish(with: result, component: currentComponent)
        }
    }
    
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
    
    private func handle(
        order: PartialPaymentOrder,
        resultCode: CheckoutResultCode,
        currentComponent: Component,
        dropInComponent: AnyDropInComponent
    ) {
        let updateDropInBlock: (() -> Void) = { [weak self] in
            self?.updateDropIn(dropInComponent, with: order, currentComponent: currentComponent)
        }
        
        // dropIn needs to be updated in both cases
        if resultCode == .refused {
            showPaymentFailedAlert(on: dropInComponent, completion: updateDropInBlock)
        } else {
            updateDropInBlock()
        }
    }
    
    private func showPaymentFailedAlert(on dropInComponent: AnyDropInComponent, completion: @escaping (() -> Void)) {
        let localizationParameters = (dropInComponent as? Localizable)?.localizationParameters
        let title = localizedString(.errorTitle, localizationParameters)
        let message = localizedString(.paymentRefusedMessage, localizationParameters)
        
        Task { @MainActor in
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            let doneTitle = localizedString(.dismissButton, localizationParameters)
            let doneAction = UIAlertAction(title: doneTitle, style: .default) { _ in
                completion()
            }
            alertController.addAction(doneAction)
            
            dropInComponent.viewController.present(alertController, animated: true)
        }
    }
    
    private func updateDropIn(_ dropInComponent: AnyDropInComponent, with order: PartialPaymentOrder, currentComponent: Component) {
        let initialInfo = SessionResponse(
            id: state.identifier,
            sessionData: state.data
        )
        Task {
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
                // Handle error
                finish(with: error, component: currentComponent)
            }
        }
    }
    
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
