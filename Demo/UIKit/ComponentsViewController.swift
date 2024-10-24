//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

internal final class ComponentsViewController: UIViewController {
    
    private lazy var componentsView = ComponentsView()
    
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
    
    private var issuerListComponentExample: IssuerListComponentExample {
        let issuerListComponent = IssuerListComponentExample()
        issuerListComponent.presenter = self
        return issuerListComponent
    }
    
    private var issuerListComponentAdvancedFlowExample: IssuerListComponentAdvancedFlowExample {
        let issuerListComponent = IssuerListComponentAdvancedFlowExample()
        issuerListComponent.presenter = self
        return issuerListComponent
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

    private var applePayComponentAdvancedFlowExample: ApplePayComponentAdvancedFlowExample {
        let applePayComponentAdvancedFlow = ApplePayComponentAdvancedFlowExample()
        applePayComponentAdvancedFlow.presenter = self
        return applePayComponentAdvancedFlow
    }

    private var applePayComponentExample: ApplePayComponentExample {
        let applePayComponent = ApplePayComponentExample()
        applePayComponent.presenter = self
        return applePayComponent
    }

    // MARK: - View
    
    override internal func loadView() {
        view = componentsView
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Components"
        
        componentsView.items = [
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
            ],
            [ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)],
            [
                ComponentsItem(title: "Configurable Pay Button", selectionHandler: presentCustomComponentView)
            ]
        ]
        
        if #available(iOS 13.0.0, *) {
            addConfigurationButton()
        }
    }
    
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
        if componentsView.isUsingSession {
            start(dropInExample)
        } else {
            start(dropInAdvancedFlowExample)
        }
    }

    // MARK: - Components

    internal func presentCardComponent() {
        if componentsView.isUsingSession {
            start(cardComponentExample)
        } else {
            start(cardComponentAdvancedFlowExample)
        }
    }
    
    internal func presentIssuerListComponent() {
        if componentsView.isUsingSession {
            start(issuerListComponentExample)
        } else {
            start(issuerListComponentAdvancedFlowExample)
        }
    }
    
    internal func presentInstantPaymentComponent() {
        if componentsView.isUsingSession {
            start(instantPaymentComponentExample)
        } else {
            start(instantPaymentComponentAdvancedFlow)
        }
    }

    internal func presentApplePayComponent() {
        if componentsView.isUsingSession {
            start(applePayComponentExample)
        } else {
            start(applePayComponentAdvancedFlowExample)
        }
    }

    internal func presentCustomComponentView() {
        let assembler = CustomComponentAssembler()
        let customComponentView = assembler.resolveCustomComponentView()
        let navigationController = UINavigationController(rootViewController: customComponentView)
        present(viewController: navigationController, completion: nil)
    }

}

// MARK: - Presenter

extension ComponentsViewController: PresenterExampleProtocol {
    
    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        if let retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }

        present(viewController: alertController, completion: nil)
    }

    internal func presentAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(viewController: alertController, completion: nil)
    }
    
    internal func showLoadingIndicator() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        componentsView.showsLoadingIndicator = true
    }
    
    internal func hideLoadingIndicator() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        componentsView.showsLoadingIndicator = false
    }

    internal func present(viewController: UIViewController, completion: (() -> Void)?) {
        topPresenter.present(viewController, animated: true, completion: completion)
    }

    internal func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}

extension UIViewController {
    var topPresenter: UIViewController {
        var topController: UIViewController = self
        while let presenter = topController.presentedViewController {
            topController = presenter
        }
        return topController
    }
}

// MARK: - Configuration, iOS13+

@available(iOS 13.0.0, *)
extension ComponentsViewController {
    
    private func addConfigurationButton() {
        let image = UIImage(systemName: "gear")
        let settingsButton = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(onSettingsTap)
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc private func onSettingsTap() {
        let configurationVC = UIHostingController(rootView: ConfigurationView(viewModel: getConfigurationVM()))
        configurationVC.isModalInPresentation = true
        present(configurationVC, animated: true, completion: nil)
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
