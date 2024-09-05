//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal final class ComponentsViewModel: ObservableObject, Identifiable {
    
    private var currentExample: ExampleContainer?

    private var dropInExample: DropInExample {
        let dropIn = DropInExample()
        dropIn.presenter = self
        return dropIn
    }

    private var dropInAdvancedFlowExample: DropInAdvancedFlowExample {
        let dropInAdvancedFlow = DropInAdvancedFlowExample()
        dropInAdvancedFlow.presenter = self
        return dropInAdvancedFlow
    }

    private var cardComponentAdvancedFlowExample: CardComponentAdvancedFlowExample {
        let cardComponentAdvancedFlow = CardComponentAdvancedFlowExample()
        cardComponentAdvancedFlow.presenter = self
        return cardComponentAdvancedFlow
    }

    private var cardComponentExample: CardComponentExample {
        let cardComponentExample = CardComponentExample()
        cardComponentExample.presenter = self
        return cardComponentExample
    }
    
    private var issuerListComponentAdvancedFlowExample: IssuerListComponentAdvancedFlowExample {
        let cardComponentAdvancedFlow = IssuerListComponentAdvancedFlowExample()
        cardComponentAdvancedFlow.presenter = self
        return cardComponentAdvancedFlow
    }

    private var issuerListComponentExample: IssuerListComponentExample {
        let cardComponentExample = IssuerListComponentExample()
        cardComponentExample.presenter = self
        return cardComponentExample
    }
    
    private var instantPaymentComponentExample: InstantPaymentComponentExample {
        let instantPaymentComponentExample = InstantPaymentComponentExample()
        instantPaymentComponentExample.presenter = self
        return instantPaymentComponentExample
    }
    
    private var instantPaymentComponentAdvancedFlow: InstantPaymentComponentAdvancedFlow {
        let instantPaymentComponentExample = InstantPaymentComponentAdvancedFlow()
        instantPaymentComponentExample.presenter = self
        return instantPaymentComponentExample
    }

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var items = [[ComponentsItem]]()
    
    @Published internal private(set) var isLoading: Bool = false
    
    @Published internal var isUsingSession: Bool = true
    
    // MARK: - Private
    
    private func start(_ example: some InitialDataFlowProtocol) {
        currentExample = .session(example)
        example.start()
    }
    
    private func start(_ example: some InitialDataAdvancedFlowProtocol) {
        currentExample = .advanced(example)
        example.start()
    }

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        if isUsingSession {
            start(dropInExample)
        } else {
            start(dropInAdvancedFlowExample)
        }
    }

    internal func presentCardComponent() {
        if isUsingSession {
            start(cardComponentExample)
        } else {
            start(cardComponentAdvancedFlowExample)
        }
    }
    
    internal func presentIssuerListComponent() {
        if isUsingSession {
            start(issuerListComponentExample)
        } else {
            start(issuerListComponentAdvancedFlowExample)
        }
    }
    
    internal func presentInstantPaymentComponent() {
        if isUsingSession {
            start(instantPaymentComponentExample)
        } else {
            start(instantPaymentComponentAdvancedFlow)
        }
    }

    internal func handleOnAppear() {
        items = [
            [ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
                ComponentsItem(
                    title: "Issuer List",
                    subtitle: "e.g. Open Banking, ...",
                    selectionHandler: presentIssuerListComponent
                ),
                ComponentsItem(
                    title: "Instant/Redirect Payment",
                    subtitle: "e.g. iDEAL, PayPal, Alipay, ...",
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
    }
}
