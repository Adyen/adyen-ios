//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal final class ComponentsViewModel: ObservableObject, Identifiable {

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var items = [[ComponentsItem]]()
    
    @Published internal private(set) var isLoading: Bool = false
    
    @Published internal var isUsingSession: Bool = true
    
    private var currentExampleComponent: ExampleComponentProtocol?

    // MARK: - DropIn Component

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        currentExampleComponent = ExampleComponentFactory.dropIn(
            forSession: isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }

    // MARK: - Components

    internal func presentCardComponent() {
        currentExampleComponent = ExampleComponentFactory.cardComponent(
            forSession: isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }
    
    internal func presentIssuerListComponent() {
        currentExampleComponent = ExampleComponentFactory.issuerListComponent(
            forSession: isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }
    
    internal func presentInstantPaymentComponent() {
        currentExampleComponent = ExampleComponentFactory.instantPaymentComponent(
            forSession: isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }

    internal func presentApplePayComponent() {
        currentExampleComponent = ExampleComponentFactory.applePayComponent(
            forSession: isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }

    internal func handleOnAppear() {
        items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
                ComponentsItem(
                    title: "Issuer List",
                    subtitle: "e.g. Ideal, Open Banking, ...",
                    selectionHandler: presentIssuerListComponent
                ),
                ComponentsItem(
                    title: "Instant/Redirect Payment",
                    subtitle: "e.g. PayPal, Alipay, ...",
                    selectionHandler: presentInstantPaymentComponent
                )
            ]
        ]
    }
    
    // MARK: - Configuration
    
    internal func presentConfiguration() {
        let configurationVC = UIHostingController(rootView: ConfigurationView(viewModel: getConfigurationVM()))
        configurationVC.isModalInPresentation = true
        present(viewController: configurationVC, completion: nil)
    }
    
    private func getConfigurationVM() -> ConfigurationViewModel {
        ConfigurationViewModel(
            configuration: ConfigurationConstants.current,
            onDone: { [weak self] in self?.onConfigurationClosed($0) }
        )
    }
    
    private func onConfigurationClosed(_ configuration: DemoAppSettings) {
        ConfigurationConstants.current = configuration
        dismiss(completion: nil)
    }
}

extension ComponentsViewModel: PresenterExampleProtocol {
    
    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }

        viewControllerToPresent = alertController
    }

    internal func presentAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewControllerToPresent = alertController
    }
    
    internal func showLoadingIndicator() {
        isLoading = true
    }
    
    internal func hideLoadingIndicator() {
        isLoading = false
    }

    internal func present(viewController: UIViewController, completion: (() -> Void)?) {
        viewControllerToPresent = viewController
        completion?()
    }

    internal func dismiss(completion: (() -> Void)?) {
        viewControllerToPresent = nil
        completion?()
        currentExampleComponent = nil
    }
}
