//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

internal final class ComponentsViewController: UIViewController {
    
    private lazy var componentsView = ComponentsView()

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
    
    private lazy var issuerListComponentExample: IssuerListComponentExample = {
        let issuerListComponent = IssuerListComponentExample()
        issuerListComponent.presenter = self
        return issuerListComponent
    }()
    
    private lazy var issuerListComponentAdvancedFlowExample: IssuerListComponentAdvancedFlowExample = {
        let issuerListComponent = IssuerListComponentAdvancedFlowExample()
        issuerListComponent.presenter = self
        return issuerListComponent
    }()
    
    private lazy var instantPaymentComponentExample: InstantPaymentComponentExample = {
        let instantPaymentComponentExample = InstantPaymentComponentExample()
        instantPaymentComponentExample.presenter = self
        return instantPaymentComponentExample
    }()
    
    private lazy var instantPaymentComponentAdvancedFlow: InstantPaymentComponentAdvancedFlow = {
        let instantPaymentComponentExample = InstantPaymentComponentAdvancedFlow()
        instantPaymentComponentExample.presenter = self
        return instantPaymentComponentExample
    }()

    private lazy var applePayComponentAdvancedFlowExample: ApplePayComponentAdvancedFlowExample = {
        let applePayComponentAdvancedFlow = ApplePayComponentAdvancedFlowExample()
        applePayComponentAdvancedFlow.presenter = self
        return applePayComponentAdvancedFlow
    }()

    private lazy var applePayComponentExample: ApplePayComponentExample = {
        let applePayComponent = ApplePayComponentExample()
        applePayComponent.presenter = self
        return applePayComponent
    }()

    // MARK: - View
    
    override internal func loadView() {
        view = componentsView
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Components"
        
        componentsView.items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
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
            [
                ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)
            ],
            [
                ComponentsItem(title: "Configurable Pay Button", selectionHandler: presentCustomComponentView)
            ]
        ]
        
        if #available(iOS 13.0.0, *) {
            addConfigurationButton()
        }
    }
    
    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        if componentsView.isUsingSession {
            dropInExample.start()
        } else {
            dropInAdvancedFlowExample.start()
        }
    }

    // MARK: - Components

    internal func presentCardComponent() {
        if componentsView.isUsingSession {
            cardComponentExample.start()
        } else {
            cardComponentAdvancedFlowExample.start()
        }
    }
    
    internal func presentIssuerListComponent() {
        if componentsView.isUsingSession {
            issuerListComponentExample.start()
        } else {
            issuerListComponentAdvancedFlowExample.start()
        }
    }
    
    internal func presentInstantPaymentComponent() {
        if componentsView.isUsingSession {
            instantPaymentComponentExample.start()
        } else {
            instantPaymentComponentAdvancedFlow.start()
        }
    }

    internal func presentApplePayComponent() {
        if componentsView.isUsingSession {
            applePayComponentExample.start()
        } else {
            applePayComponentAdvancedFlowExample.start()
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
