//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenNetworking
import AdyenSession
@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenCard

protocol CustomComponentPresenterProtocol {
    var cardViewController: UIViewController { get }
    func performPayment()
    func viewDidLoad()
}

class CustomComponentPresenter: CustomComponentPresenterProtocol {

    // MARK: - Properties

    weak var view: CustomComponentViewProtocol?
    private var cardComponent: CardComponent?
    private let apiClient: APIClientProtocol

    private lazy var adyenContext: AdyenContext = {
        let apiContext = ConfigurationConstants.apiContext
        return AdyenContext(apiContext: apiContext, payment: nil)
    }()

    private lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: self.adyenContext)
        handler.configuration.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        handler.configuration.threeDS.requestorAppURL = ConfigurationConstants.returnUrl
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Initializers

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        self.cardComponent = resolveCardComponent()
    }

    // MARK: - Public

    func viewDidLoad() {}

    func performPayment() {
        cardComponent?.submit()
    }

    var cardViewController: UIViewController {
        guard let cardComponent else {
            fatalError("Card component has not been initialized")
        }

        return cardComponent.viewController
    }

    // MARK: - Private

    private func performPayment(with data: PaymentComponentData,
                                from component: PaymentComponent) {
        view?.startActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            let request = PaymentsRequest(data: data)
            self.apiClient.perform(request) { [weak self] result in
                self?.handlePayment(result: result)
            }
        }
    }

    private func handlePayment(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                adyenActionComponent.handle(action)
            } else {
                stopLoading()
                handlePayment(response: response)
            }
        case let .failure(error):
            handlePayment(error: error)
        }
    }

    private func handlePayment(response: PaymentsResponse) {
        switch response.resultCode {
        case .authorised, .pending, .received:
            view?.dismiss()
        default:
            handlePayment(error: nil)
        }
    }

    private func resolveCardComponent() -> CardComponent {
        let paymentMethod = CardPaymentMethod(type: .scheme,
                                              name: "Card",
                                              fundingSource: .debit,
                                              brands: [.visa])
        var billingAddressConfiguration = BillingAddressConfiguration()
        billingAddressConfiguration.mode = .none

        let configuration = CardComponent.Configuration(showsSubmitButton: false, billingAddress: billingAddressConfiguration)

        let cardComponent = CardComponent(paymentMethod: paymentMethod,
                                          context: adyenContext,
                                          configuration: configuration)
        cardComponent.delegate = self
        return cardComponent
    }
}

extension CustomComponentPresenter: PaymentComponentDelegate {

    func didSubmit(_ data: Adyen.PaymentComponentData,
                   from component: any Adyen.PaymentComponent) {
        performPayment(with: data, from: component)
    }
    
    func didFail(with error: any Error,
                 from component: any Adyen.PaymentComponent) {
        handlePayment(error: error)
    }

    // MARK: - Private

    private func handlePayment(error: Error?) {
        stopLoading()
        let alertViewController = UIAlertController(title: "Payment failed",
                                                    message: "There was error processing the payment. \(error?.localizedDescription ?? "")",
                                                    preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            alertViewController.dismiss(animated: true)
        }
        alertViewController.addAction(doneAction)
        view?.present(view: alertViewController, animated: true)
    }

    private func stopLoading() {
        view?.stopActivityIndicator()
        cardComponent?.stopLoadingIfNeeded()
    }
}

extension CustomComponentPresenter: ActionComponentDelegate {
    
    internal func didFail(with error: Error, from component: ActionComponent) {
        handlePayment(error: error)
    }

    internal func didComplete(from component: ActionComponent) { /* Empty implementation */ }

    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let request = PaymentDetailsRequest(
            details: data.details,
            paymentData: data.paymentData,
            merchantAccount: ConfigurationConstants.current.merchantAccount
        )
        apiClient.perform(request) { [weak self] result in
            self?.handlePayment(result: result)
        }
    }
}

extension CustomComponentPresenter: PresentationDelegate {
    
    func present(component: any PresentableComponent) {
        let viewController = component.viewController
        view?.present(view: viewController, animated: true)
    }
}
