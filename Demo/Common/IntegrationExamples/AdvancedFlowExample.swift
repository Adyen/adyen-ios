////
//// Copyright (c) 2023 Adyen N.V.
////
//// This file is open source and available under the MIT license. See the LICENSE file for more info.
////
//

import AdyenActions
import AdyenComponents
import AdyenDropIn

internal final class AdvancedFlowExample: AdvancedFlowExampleProtocol {

    internal var advancedFlowComponent: PresentableComponent?
    internal var paymentMethods: PaymentMethods?
    internal weak var presenter: PresenterExampleProtocol?

    internal lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: context)
        handler.configuration.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        handler.configuration.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    internal init() {}

    // MARK: - Networking

    internal func requestInitialData() {
        requestPaymentMethods(order: nil) { [weak self] paymentMethods, errorResponse in
            guard paymentMethods != nil else {
                guard let errorResponse = errorResponse else {
                    return
                }
                self?.presentAlert(with: errorResponse) { [weak self] in
                    self?.requestPaymentMethods(order: nil, completion: nil)
                }
                return
            }
            self?.paymentMethods = paymentMethods
        }
    }

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func presentDropInComponent() {
        guard let dropIn = dropInComponent(from: paymentMethods) else { return }

        dropIn.delegate = self
        dropIn.partialPaymentDelegate = self
        dropIn.storedPaymentMethodsDelegate = self
        advancedFlowComponent = dropIn

        presenter?.present(viewController: dropIn.viewController, completion: nil)
    }

    internal func dropInComponent(from paymentMethods: PaymentMethods?) -> DropInComponent? {
        guard let paymentMethods = paymentMethods else { return nil }

        let configuration = DropInComponent.Configuration()

        if let applePayPayment = try? ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                      brand: ConfigurationConstants.appName) {
            configuration.applePay = .init(payment: applePayPayment,
                                           merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier)
        }

        configuration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        configuration.actionComponent.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        configuration.card.billingAddress.mode = .postalCode
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = true

        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: context,
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)

        return component
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else if let order = response.order,
                      let remainingAmount = order.remainingAmount,
                      remainingAmount.value > 0 {
                handle(order)
            } else {
                finish(with: response)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

    // MARK: - Payment response handling

    internal func handle(_ order: PartialPaymentOrder) {
        requestPaymentMethods(order: order) { [weak self] paymentMethods, errorResponse in
            guard let paymentMethods = paymentMethods else {
                if let error = errorResponse {
                    self?.presentAlert(with: error) { [weak self] in
                        self?.requestPaymentMethods(order: order, completion: nil)
                    }
                }
                return
            }
            self?.handle(order, paymentMethods)
        }
    }

    internal func handle(_ action: Action) {
        if let advancedFlowAsActionComponent = advancedFlowComponent as? ActionHandlingComponent {
            /// In case current component is a `DropInComponent` that implements `ActionHandlingComponent`
            advancedFlowAsActionComponent.handle(action)
        } else {
            /// In case current component is an individual component like `CardComponent`
            adyenActionComponent.handle(action)
        }
    }

    private func handle(_ order: PartialPaymentOrder, _ paymentMethods: PaymentMethods) {
        do {
            try (advancedFlowComponent as? DropInComponent)?.reload(with: order, paymentMethods)
        } catch {
            finish(with: error)
        }
    }

    internal func finish(with result: PaymentsResponse) {
        let success = result.resultCode == .authorised || result.resultCode == .received || result.resultCode == .pending
        let message = "\(result.resultCode.rawValue) \(result.amount?.formatted ?? "")"
        finalize(success, message)
    }

    internal func finish(with error: Error) {
        let message: String
        if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
            message = "Cancelled"
        } else {
            message = error.localizedDescription
        }
        finalize(false, message)
    }

    private func finalize(_ success: Bool, _ message: String) {
        advancedFlowComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self = self else { return }
            self.dismissAndShowAlert(success, message)
        }
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}
extension AdvancedFlowExample: DropInComponentDelegate {

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didSubmit(data, from: component)
    }

    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, from: component)
    }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didProvide(data, from: component)
    }

    func didComplete(from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didComplete(from: component)
    }

    func didFail(with error: Error, from component: ActionComponent, in dropInComponent: AnyDropInComponent) {
        didFail(with: error, from: component)
    }

    internal func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component.paymentMethod.name)")
    }

    internal func didFail(with error: Error, from dropInComponent: AnyDropInComponent) {
        finish(with: error)
    }

}

extension AdvancedFlowExample: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }

}

extension AdvancedFlowExample: PartialPaymentDelegate {

    internal enum GiftCardError: Error, LocalizedError {
        case noBalance

        internal var errorDescription: String? {
            switch self {
            case .noBalance:
                return "No Balance"
            }
        }
    }

    internal func checkBalance(with data: PaymentComponentData,
                               component: Component,
                               completion: @escaping (Result<Balance, Error>) -> Void) {
        let request = BalanceCheckRequest(data: data)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }

    private func handle(result: Result<BalanceCheckResponse, Error>,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        switch result {
        case let .success(response):
            handle(response: response, completion: completion)
        case let .failure(error):
            completion(.failure(error))
        }
    }

    private func handle(response: BalanceCheckResponse, completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            completion(.failure(GiftCardError.noBalance))
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    internal func requestOrder(for component: Component,
                               completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(amount: ConfigurationConstants.current.amount,
                                         reference: UUID().uuidString)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }

    private func handle(result: Result<CreateOrderResponse, Error>,
                        completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        switch result {
        case let .success(response):
            completion(.success(response.order))
        case let .failure(error):
            completion(.failure(error))
        }
    }

    internal func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        let request = CancelOrderRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<CancelOrderResponse, Error>) {
        switch result {
        case let .success(response):
            if response.resultCode == .received {
                presenter?.presentAlert(withTitle: "Order Cancelled", message: nil)
            } else {
                presenter?.presentAlert(withTitle: "Something went wrong, order is not canceled but will expire.", message: nil)
            }
        case let .failure(error):
            finish(with: error)
        }
    }

    // MARK: - Presentation

    private func present(_ component: PresentableComponent, delegate: (PaymentComponentDelegate & ActionComponentDelegate)?) {
        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = delegate
        }

        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = delegate
        }

        advancedFlowComponent = component
        guard component.requiresModalPresentation else {
            presenter?.present(viewController: component.viewController, completion: nil)
            return
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                           target: self,
                                                                           action: #selector(cancelPressed))
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelPressed() {
        advancedFlowComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }

}

extension AdvancedFlowExample: StoredPaymentMethodsDelegate {
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping (Bool) -> Void) {
        let request = DisableStoredPaymentMethodRequest(recurringDetailReference: storedPaymentMethod.identifier)
        palApiClient.perform(request) { [weak self] result in
            self?.handleDisableResult(result, completion: completion)
        }
    }

    private func handleDisableResult(_ result: Result<DisableStoredPaymentMethodRequest.ResponseType, Error>, completion: (Bool) -> Void) {
        switch result {
        case let .failure(error):
            presentAlert(with: error, retryHandler: nil)
            completion(false)
        case let .success(response):
            completion(response.response == .detailsDisabled)
        }
    }
}

extension AdvancedFlowExample: PresentationDelegate {

    internal func present(component: PresentableComponent) {
        present(component, delegate: self)
    }
}

extension AdvancedFlowExample: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        finish(with: error)
    }

    internal func didComplete(from component: ActionComponent) {
        finish(with: .received)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        (component as? PresentableComponent)?.viewController.view.isUserInteractionEnabled = false
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
}
