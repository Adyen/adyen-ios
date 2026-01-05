//
// Copyright (c) Adyen N.V.
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
        startLoading()
        
        Task {
            do {
                let sessionResponse = try await requestSessionInitialInfo()
                let component = try await self.blikComponent(from: sessionResponse)
                self.adyenComponent = component
                await hideLoading()
                await present(component: component)
            } catch {
                await hideLoading()
                await handleError(error)
            }
        }
    }
    
    private func blikComponent(from sessionResponse: SessionResponse) async throws -> AdyenCheckoutComponent {
        
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
              let blikPaymentMethod = paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self),
              let component = checkout.createComponent(with: blikPaymentMethod) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: BLIKPaymentMethod.self)
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
    
    private func viewController(for component: AdyenCheckoutComponent) -> UIViewController {
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
//        component?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }
}

extension BLIKComponentExample: PresentationDelegate {
    
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
