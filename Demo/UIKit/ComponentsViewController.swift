//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

internal final class ComponentsViewController: UIViewController {
    
    private lazy var componentsView = ComponentsView()

    private var currentExampleComponent: ExampleComponentProtocol?

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
                    subtitle: "e.g. Ideal, Open Banking, ...",
                    selectionHandler: presentIssuerListComponent
                ),
                ComponentsItem(
                    title: "Instant/Redirect Payment",
                    subtitle: "e.g. PayPal, Alipay, ...",
                    selectionHandler: presentInstantPaymentComponent
                )
            ],
            [
                ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)
            ]
        ]
        
        if #available(iOS 13.0.0, *) {
            addConfigurationButton()
        }
    }
    
    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        currentExampleComponent = ExampleComponentFactory.dropIn(
            forSession: componentsView.isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }

    // MARK: - Components

    internal func presentCardComponent() {
        currentExampleComponent = ExampleComponentFactory.cardComponent(
            forSession: componentsView.isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }
    
    internal func presentIssuerListComponent() {
        currentExampleComponent = ExampleComponentFactory.issuerListComponent(
            forSession: componentsView.isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }
    
    internal func presentInstantPaymentComponent() {
        currentExampleComponent = ExampleComponentFactory.instantPaymentComponent(
            forSession: componentsView.isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
    }

    internal func presentApplePayComponent() {
        currentExampleComponent = ExampleComponentFactory.applePayComponent(
            forSession: componentsView.isUsingSession,
            presenter: self
        )
        
        currentExampleComponent?.start()
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
        dismiss(animated: true) {
            completion?()
            self.currentExampleComponent = nil
        }
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
