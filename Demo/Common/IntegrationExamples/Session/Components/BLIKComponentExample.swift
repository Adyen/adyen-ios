//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCheckout
import AdyenComponents

@MainActor
internal final class BLIKComponentExample: InitialDataFlowProtocol {
    
    internal weak var presenter: PresenterExampleProtocol?
    
    private var checkout: SessionCheckout?
    private var adyenComponent: CheckoutPaymentComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?

    func start() {
        startLoading()
        
        Task {
            do {
                let sessionResponse = try await requestSessionInitialInfo()
                let component = try await self.blikComponent(from: sessionResponse)
                self.adyenComponent = component
                hideLoading()
                present(component: component)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }
    
    private func blikComponent(from sessionResponse: SessionResponse) async throws -> CheckoutPaymentComponent {
        
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
        
        let checkout = try await Checkout.setup(
            with: sessionResponse,
            configuration: configuration,
            presentationDelegate: self
        )
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onFailure { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }
        
        self.checkout = checkout
        
        return try checkout.createPaymentComponent(for: .blik)
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
    private func present(component: CheckoutPaymentComponent) {
        presenter?.present(viewController: viewController(for: component), completion: nil)
    }
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }
    
    private func viewController(for component: CheckoutPaymentComponent) -> UIViewController {
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
    
    func present(viewController: UIViewController) {
        presenter?.present(viewController: viewController, completion: nil)
    }
}
