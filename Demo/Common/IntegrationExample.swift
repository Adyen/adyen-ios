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

internal final class IntegrationExample {
    internal let payment = Payment(amount: Configuration.amount, countryCode: Configuration.countryCode)
    internal let environment = Configuration.componentsEnvironment

    internal var paymentMethods: PaymentMethods?
    internal var currentComponent: PresentableComponent?
    internal var paymentInProgress: Bool = false

    internal weak var presenter: Presenter?

    // MARK: - Action Handling for Components

    internal lazy var actionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent()
        handler.redirectComponentStyle = RedirectComponentStyle()
        handler.delegate = self
        handler.presentationDelegate = self
        handler.environment = environment
        handler.clientKey = Configuration.clientKey
        return handler
    }()

    // MARK: - Networking

    // swiftlint:disable:enable force_try
    internal lazy var apiClient: APIClientProtocol = {
        if CommandLine.arguments.contains("-UITests") {
            let apiClient = APIClientMock()
            let data = try! Data(contentsOf: Bundle.main.url(forResource: "payment_methods_response", withExtension: "json")!)
            let response = try! JSONDecoder().decode(PaymentMethodsResponse.self, from: data)
            apiClient.mockedResults = [.success(response)]
            return apiClient
        } else {
            return DefaultAPIClient()
        }
    }()
    // swiftlint:disable:disable force_try

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

    internal func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending

        stopLoadingIfNeeded(success) { [weak self] in
            self?.presenter?.dismiss { [weak self] in
                self?.presentAlert(withTitle: resultCode.rawValue)
            }
        }
    }

    internal func finish(with error: Error) {
        let isCancelled = ((error as? ComponentError) == .cancelled)

        stopLoadingIfNeeded(false) { [weak self] in
            self?.presenter?.dismiss { [weak self] in
                if !isCancelled { self?.presentAlert(with: error) }
            }
        }
    }

    private func stopLoadingIfNeeded(_ success: Bool, completion: (() -> Void)?) {
        if let currentComponent = currentComponent as? LoadingComponent {
            currentComponent.stopLoading(withSuccess: success, completion: completion)
        } else {
            completion?()
        }
    }

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func presentAlert(withTitle title: String) {
        presenter?.presentAlert(withTitle: title)
    }
}
