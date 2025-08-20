//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenComponents

internal final class BLIKComponentExample: InitialDataFlowProtocol {
    
    internal weak var presenter: PresenterExampleProtocol?
    
    private var adyenCheckout: AdyenCheckout?
    private var adyenComponent: AdyenCheckoutComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    // comes from demo app protocol, unused on new structure
    internal lazy var context: AdyenContext = generateContext()
    
    func start() {
        presenter?.showLoadingIndicator()
        requestSessionInitialInfo { [weak self] result in
            guard let self else { return }
            
            Task {
                do {
                    switch result {
                    case let .success(sessionResponse):
                        try await self.presentBlik(with: sessionResponse)
                    case let .failure(error):
                        throw error
                    }
                } catch {
                    await self.handle(error)
                }
            }
        }
    }
    
    @MainActor
    private func presentBlik(with sessionResponse: SessionResponse) async throws {
        
        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            BLIKComponentConfiguration()
        }
        .onComplete { [weak self] result in
            self?.presenter?.dismiss {
                self?.presenter?.presentAlert(withTitle: "Result Code", message: result.resultCode.rawValue)
            }
        }
        
        let checkout = try await AdyenCheckout.setup(with: sessionResponse.sessionId, sessionData: sessionResponse.sessionData, configuration: configuration, presentationDelegate: self)
        
        guard let paymentMethods = checkout.paymentMethods,
              let blikPaymentMethod = paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self),
              let component = checkout.createComponent(with: blikPaymentMethod) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: BLIKPaymentMethod.self)
        }
        
        presenter?.hideLoadingIndicator()
        
        self.adyenCheckout = checkout
        self.adyenComponent = component
        self.presenter?.present(viewController: viewController(for: component), completion: nil)
    }
    
    @MainActor
    private func handle(_ error: Error) {
        presenter?.hideLoadingIndicator()
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }
    
    private func viewController(for component: AdyenCheckoutComponent) -> UIViewController {
        let navigation = UINavigationController(rootViewController: component.viewController!)
        component.viewController?.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }
    
    @objc private func cancelPressed() {
        // TODO: component cancellation?
//        component?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}

extension BLIKComponentExample: PresentationDelegate {
    
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
