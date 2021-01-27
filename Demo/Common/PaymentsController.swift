//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenDropIn
import AdyenComponents
import UIKit

internal protocol Presenter: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

internal final class PaymentsController {
    private let payment = Payment(amount: Configuration.amount, countryCode: Configuration.countryCode)
    private let environment = Configuration.componentsEnvironment

    private var paymentMethods: PaymentMethods?
    private var currentComponent: PresentableComponent?
    private var paymentInProgress: Bool = false

    internal weak var presenter: Presenter?

    // MARK: - Components

    private lazy var actionComponent: AdyenActionHandler = {
        let handler = AdyenActionHandler()
        handler.redirectComponentStyle = dropInComponentStyle.redirectComponent
        handler.delegate = self
        handler.presentationDelegate = self
        handler.environment = environment
        handler.clientKey = Configuration.clientKey
        return handler
    }()

    private func present(_ component: PresentableComponent) {
        component.environment = environment
        component.clientKey = Configuration.clientKey
        component.payment = payment

        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = self
        }

        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = self
        }

        currentComponent = component
        guard component.requiresModalPresentation else {
            presenter?.present(viewController: component.viewController, completion: nil)
            return
        }

        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(cancelDidPress))
        presenter?.present(viewController: navigation, completion: nil)
    }

    @objc private func cancelDidPress() {
        currentComponent?.didCancel()

        if let paymentComponent = self.currentComponent as? PaymentComponent {
            paymentComponent.delegate?.didFail(with: ComponentError.cancelled, from: paymentComponent)
        }
    }

    // MARK: - DropIn Component

    private lazy var dropInComponentStyle = DropInComponent.Style()

    internal func presentDropInComponent() {
        guard let paymentMethods = paymentMethods else { return }
        let configuration = DropInComponent.PaymentMethodsConfiguration()
        configuration.clientKey = Configuration.clientKey
        configuration.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        configuration.applePay.summaryItems = Configuration.applePaySummaryItems
        configuration.environment = environment
        configuration.localizationParameters = nil

        let component = DropInComponent(paymentMethods: paymentMethods,
                                        paymentMethodsConfiguration: configuration,
                                        style: dropInComponentStyle,
                                        title: Configuration.appName)
        component.delegate = self
        present(component)
    }

    // MARK: - Standalone Components

    internal func presentCardComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let component = CardComponent(paymentMethod: paymentMethod,
                                      configuration: CardComponent.Configuration(),
                                      clientKey: Configuration.clientKey,
                                      style: dropInComponentStyle.formComponent)
        component.environment = environment
        component.clientKey = Configuration.clientKey
        component.cardComponentDelegate = self
        present(component)
    }

    internal func presentIdealComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod,
                                       style: dropInComponentStyle.listComponent)
        present(component)
    }

    internal func presentSEPADirectDebitComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 style: dropInComponentStyle.formComponent)
        component.delegate = self
        present(component)
    }

    internal func presentMBWayComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: MBWayPaymentMethod.self) else { return }
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       style: dropInComponentStyle.formComponent)
        component.delegate = self
        present(component)
    }

    internal func presentApplePayComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: ApplePayPaymentMethod.self) else { return }
        let config = ApplePayComponent.Configuration(paymentMethod: paymentMethod,
                                                     summaryItems: Configuration.applePaySummaryItems,
                                                     merchantIdentifier: Configuration.applePayMerchantIdentifier)
        let component = try? ApplePayComponent(payment: payment,
                                               configuration: config) {
            print("ApplePay dismissed")
        }
        component?.delegate = self
        guard let presentableComponent = component else { return }
        present(presentableComponent)
    }

    // MARK: - Networking

    private lazy var apiClient: APIClientProtocol = {
        if CommandLine.arguments.contains("-UITests") {
            return apiClientMock
        } else {
            return DefaultAPIClient()
        }
    }()

    private lazy var apiClientMock: APIClientProtocol = {
        let apiClient = APIClientMock()
        // swiftlint:disable:next force_try
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "payment_methods_response", withExtension: "json")!)
        // swiftlint:disable:next force_try
        let response = try! JSONDecoder().decode(PaymentMethodsResponse.self, from: data)
        apiClient.mockedResults = [.success(response)]
        return apiClient
    }()

    internal func requestPaymentMethods() {
        let request = PaymentMethodsRequest()
        apiClient.perform(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.paymentMethods = response.paymentMethods
            case let .failure(error):
                self.presentAlert(with: error, retryHandler: self.requestPaymentMethods)
            }
        }
    }

    private func performPayment(with data: PaymentComponentData) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    private func performPaymentDetails(with data: ActionComponentData) {
        let request = PaymentDetailsRequest(details: data.details,
                                            paymentData: data.paymentData,
                                            merchantAccount: Configuration.merchantAccount)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            currentComponent?.stopLoading(withSuccess: false) { [weak self] in
                self?.presenter?.dismiss(completion: nil)
                self?.presentAlert(with: error)
            }
        }
    }

    private func handle(_ action: Action) {
        guard paymentInProgress else { return }

        if let dropInComponent = currentComponent as? DropInComponent {
            return dropInComponent.handle(action)
        }

        actionComponent.perform(action)
    }

    private func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending

        currentComponent?.stopLoading(withSuccess: success) { [weak self] in
            self?.presenter?.dismiss(completion: nil)
            self?.presentAlert(withTitle: resultCode.rawValue)
        }
    }

    private func finish(with error: Error) {
        let isCancelled = ((error as? ComponentError) == .cancelled)

        presenter?.dismiss { [weak self] in
            if !isCancelled {
                self?.presentAlert(with: error)
            }
        }
    }

    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    private func presentAlert(withTitle title: String) {
        presenter?.presentAlert(withTitle: title)
    }
}

extension PaymentsController: DropInComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
        performPayment(with: data)
        paymentInProgress = true
    }

    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        performPaymentDetails(with: data)
    }

    internal func didFail(with error: Error, from component: DropInComponent) {
        paymentInProgress = false
        finish(with: error)
    }

    internal func didCancel(component: PresentableComponent, from dropInComponent: DropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component)")
    }

}

extension PaymentsController: PaymentComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        performPayment(with: data)
    }

    internal func didFail(with error: Error, from component: PaymentComponent) {
        paymentInProgress = false
        finish(with: error)
    }

}

extension PaymentsController: ActionComponentDelegate {

    internal func didFail(with error: Error, from component: ActionComponent) {
        paymentInProgress = false
        finish(with: error)
    }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        performPaymentDetails(with: data)
    }
}

extension PaymentsController: CardComponentDelegate {
    internal func didChangeBIN(_ value: String, component: CardComponent) {
        print("Current BIN: \(value)")
    }

    internal func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        print("Current card type: \((value ?? []).reduce("") { "\($0), \($1)" })")
    }
}

extension PaymentsController: PresentationDelegate {
    internal func present(component: PresentableComponent, disableCloseButton: Bool) {
        present(component)
    }
}
