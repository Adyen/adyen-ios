//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal final class PaymentsViewModel: ObservableObject, Identifiable {

    private lazy var dropInExample: DropInExample = {
        let dropIn = DropInExample()
        dropIn.presenter = self
        return dropIn
    }()

    private lazy var dropInAdvancedFlowExample: DropInAdvancedFlowExample = {
        let dropInAdvancedFlow = DropInAdvancedFlowExample()
        dropInAdvancedFlow.presenter = self
        return dropInAdvancedFlow
    }()

    private lazy var cardComponentAdvancedFlowExample: CardComponentAdvancedFlowExample = {
        let cardComponentAdvancedFlow = CardComponentAdvancedFlowExample()
        cardComponentAdvancedFlow.presenter = self
        return cardComponentAdvancedFlow
    }()

    private lazy var cardComponentExample: CardComponentExample = {
        let cardComponentExample = CardComponentExample()
        cardComponentExample.presenter = self
        return cardComponentExample
    }()
    
    private lazy var issuerListComponentAdvancedFlowExample: IssuerListComponentAdvancedFlowExample = {
        let cardComponentAdvancedFlow = IssuerListComponentAdvancedFlowExample()
        cardComponentAdvancedFlow.presenter = self
        return cardComponentAdvancedFlow
    }()

    private lazy var issuerListComponentExample: IssuerListComponentExample = {
        let cardComponentExample = IssuerListComponentExample()
        cardComponentExample.presenter = self
        return cardComponentExample
    }()

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var items = [[ComponentsItem]]()
    
    @Published internal private(set) var isLoading: Bool = false
    
    @Published internal var isUsingSession: Bool = true

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        if isUsingSession {
            dropInExample.start()
        } else {
            dropInAdvancedFlowExample.start()
        }
    }

    internal func presentCardComponent() {
        if isUsingSession {
            cardComponentExample.start()
        } else {
            cardComponentAdvancedFlowExample.start()
        }
    }
    
    internal func presentIssuerListComponent() {
        if isUsingSession {
            issuerListComponentExample.start()
        } else {
            issuerListComponentAdvancedFlowExample.start()
        }
    }

    // TODO: add for other PM

    internal func viewDidAppear() {
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

extension PaymentsViewModel: PresenterExampleProtocol {
    
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
