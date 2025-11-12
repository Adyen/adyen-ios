//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import AdyenCheckout
import AdyenComponents

internal final class CardComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties
    
    internal weak var presenter: PresenterExampleProtocol?

    private var adyenCheckout: AdyenCheckout?
    private var adyenComponent: AdyenCheckoutComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    internal lazy var context: AdyenContext = generateContext()

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        startLoading()
        
        Task {
            do {
                let sessionResponse = try await requestSessionInitialInfo()
                let component = try await self.cardComponent(from: sessionResponse)
                self.adyenComponent = component
                await hideLoading()
                await present(component: component)
            } catch {
                await hideLoading()
                await handleError(error)
            }
        }
    }
    
    // MARK: - Presentation
    
    private func cardComponent(from sessionResponse: SessionResponse) async throws -> AdyenCheckoutComponent {
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            ConfigurationConstants.current.cardConfiguration
        }
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onError { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }
        
        let checkout = try await AdyenCheckout.setup(
            with: sessionResponse.sessionId,
            sessionData: sessionResponse.sessionData,
            configuration: configuration,
            presentationDelegate: self
        )
        
        self.adyenCheckout = checkout
        
        guard let paymentMethods = checkout.paymentMethods,
              let blikPaymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self),
              let component = checkout.createComponent(with: blikPaymentMethod) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: CardPaymentMethod.self)
        }
        
        return component
    }

    private func startLoading() {
        presenter?.showLoadingIndicator()
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }
    
    @MainActor
    private func hideLoading() {
        presenter?.hideLoadingIndicator()
    }
    
    @MainActor
    private func present(component: AdyenCheckoutComponent) {
        presenter?.present(viewController: viewController(for: component), completion: nil)
    }
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
}

extension CardComponentExample: CardComponentDelegate {

    func didSubmit(lastFour: String, finalBIN: String, component: CardComponent) {
        print("Card used: **** **** **** \(lastFour)")
        print("Final BIN: \(finalBIN)")
    }

    internal func didChangeBIN(_ value: String, component: CardComponent) {
        print("Current BIN: \(value)")
    }

    internal func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        print("Current card type: \((value ?? []).reduce("") { "\($0), \($1)" })")
    }
}

extension CardComponentExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}

private extension CardComponentExample {
    
    func viewController(for component: AdyenCheckoutComponent) -> UIViewController {
        guard let viewController = component.viewController else { fatalError("Cannot find component's view controller") }
        
        let navigation = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }
    
    @objc private func cancelPressed() {
        // TODO: how to do component cancellation
//        cardComponent?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}
