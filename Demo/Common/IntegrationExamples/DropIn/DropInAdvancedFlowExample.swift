//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenActions
import AdyenComponents
import AdyenDropIn

internal final class DropInAdvancedFlowExample: InitialDataAdvancedFlowProtocol {
    
    internal weak var presenter: PresenterExampleProtocol?

    private var dropInComponent: DropInComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var palApiClient = ApiClientHelper.generatePalApiClient()

    // MARK: - Initializers

    internal init() {}
    
    internal func start() {
        presenter?.showLoadingIndicator()
        requestPaymentMethods(order: nil) { [weak self] result in
            guard let self else { return }

            self.presenter?.hideLoadingIndicator()

            switch result {
            case let .success(paymentMethods):
                self.presentComponent(with: paymentMethods)

            case let .failure(error):
                self.presenter?.presentAlert(with: error, retryHandler: nil)
            }
        }
    }
    
    // MARK: - Presentation
    
    private func presentComponent(with paymentMethods: PaymentMethods) {
        let dropIn = dropInComponent(from: paymentMethods)
        presenter?.present(viewController: dropIn.viewController, completion: nil)
        dropInComponent = dropIn
    }

    private func dropInComponent(from paymentMethods: PaymentMethods) -> DropInComponent {
        let configuration = dropInConfiguration(from: paymentMethods)
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: context,
                                        configuration: configuration,
                                        title: ConfigurationConstants.appName)
        
        component.delegate = self
        component.partialPaymentDelegate = self
        component.storedPaymentMethodsDelegate = self

        return component
    }
    
    private func dropInConfiguration(from paymentMethods: PaymentMethods) -> DropInComponent.Configuration {
        let configuration = DropInComponent.Configuration()

        if let applePayPayment = try? ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                      brand: ConfigurationConstants.appName) {
            configuration.applePay = .init(payment: applePayPayment,
                                           merchantIdentifier: ConfigurationConstants.current.applePayConfiguration.merchantIdentifier)
            configuration.applePay?.allowOnboarding = ConfigurationConstants.current.applePayConfiguration.allowOnboarding
        }

        configuration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        configuration.actionComponent.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        configuration.card = ConfigurationConstants.current.cardDropInConfiguration
        configuration.allowsSkippingPaymentList = ConfigurationConstants.current.dropInSettings.allowsSkippingPaymentList
        configuration.allowPreselectedPaymentView = ConfigurationConstants.current.dropInSettings.allowPreselectedPaymentView
        // swiftlint:disable:next line_length
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = ConfigurationConstants.current.dropInSettings.paymentMethodsList.allowDisablingStoredPaymentMethods
        return configuration
    }

    // MARK: - Payment response handling

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                dropInComponent?.handle(action)
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

    private func handle(_ order: PartialPaymentOrder) {
        requestPaymentMethods(order: order) { [weak self] response in
            switch response {
            case let .success(paymentMethods):
                self?.handle(order, paymentMethods)
            case let .failure(error):
                self?.presenter?.presentAlert(with: error, retryHandler: {
                    self?.handle(order)
                })
            }
        }
    }

    private func handle(_ order: PartialPaymentOrder, _ paymentMethods: PaymentMethods) {
        do {
            try dropInComponent?.reload(with: order, paymentMethods)
        } catch {
            finish(with: error)
        }
    }

    private func finish(with result: PaymentsResponse) {
        let success = result.isAccepted
        let message = "\(result.resultCode.rawValue) \(result.amount?.formatted ?? "")"
        finalize(success, message)
    }

    private func finish(with error: Error) {
        let message: String
        if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
            message = "Cancelled"
        } else {
            message = error.localizedDescription
        }
        finalize(false, message)
    }

    private func finalize(_ success: Bool, _ message: String) {
        dropInComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self else { return }
            self.dismissAndShowAlert(success, message)
        }
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss { [weak self] in
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self?.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}

extension DropInAdvancedFlowExample: DropInComponentDelegate {

    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request) { [weak self] result in
            self?.paymentResponseHandler(result: result)
        }
    }

    func didFail(with error: Error, from component: PaymentComponent, in dropInComponent: AnyDropInComponent) {
        finish(with: error)
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

extension DropInAdvancedFlowExample: PartialPaymentDelegate {

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

}

extension DropInAdvancedFlowExample: StoredPaymentMethodsDelegate {
    internal func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping (Bool) -> Void) {
        let request = DisableStoredPaymentMethodRequest(recurringDetailReference: storedPaymentMethod.identifier)
        palApiClient.perform(request) { [weak self] result in
            self?.handleDisableResult(result, completion: completion)
        }
    }

    private func handleDisableResult(_ result: Result<DisableStoredPaymentMethodRequest.ResponseType, Error>, completion: (Bool) -> Void) {
        switch result {
        case let .failure(error):
            self.presenter?.presentAlert(with: error, retryHandler: nil)
            completion(false)
        case let .success(response):
            completion(response.response == .detailsDisabled)
        }
    }
}

extension DropInAdvancedFlowExample: ActionComponentDelegate {

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
        apiClient.perform(request) { [weak self] result in
            self?.paymentResponseHandler(result: result)
        }
    }
}
