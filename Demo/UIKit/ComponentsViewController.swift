//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

internal final class ComponentsViewController: UIViewController, Presenter {
    
    private lazy var componentsView = ComponentsView()

    private lazy var integrationExample: IntegrationExample = {
        let integrationExample = IntegrationExample()
        integrationExample.presenter = self
        return integrationExample
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
                ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
                ComponentsItem(title: "Online Banking PL", selectionHandler: presentOnlineBankingPolandComponent),
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent),
                ComponentsItem(title: "BACS Direct Debit", selectionHandler: presentBACSDirectDebitComponent),
                ComponentsItem(title: "MB WAY", selectionHandler: presentMBWayComponent),
                ComponentsItem(title: "Convenience Stores", selectionHandler: presentConvenienceStore)
            ],
            [
                ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)
            ]
        ]
        
        requestInitialData()
        
        if #available(iOS 13.0.0, *) {
            addConfigurationButton()
        }
    }
    
    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentDropInComponentSession()
        } else {
            integrationExample.presentDropInComponent()
        }
    }

    internal func presentCardComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentCardComponentSession()
        } else {
            integrationExample.presentCardComponent()
        }
    }

    internal func presentIdealComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentIdealComponentSession()
        } else {
            integrationExample.presentIdealComponent()
        }
    }

    internal func presentOnlineBankingPolandComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentOnlineBankingPolandComponent()
        } else {
            integrationExample.presentOnlineBankingPolandComponentSession()
        }
    }

    internal func presentSEPADirectDebitComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentSEPADirectDebitComponentSession()
        } else {
            integrationExample.presentSEPADirectDebitComponent()
        }
    }

    internal func presentBACSDirectDebitComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentBACSDirectDebitComponentSession()
        } else {
            integrationExample.presentBACSDirectDebitComponent()
        }
    }

    internal func presentMBWayComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentMBWayComponentSession()
        } else {
            integrationExample.presentMBWayComponent()
        }
    }

    internal func presentApplePayComponent() {
        if componentsView.isUsingSession {
            integrationExample.presentApplePayComponentSession()
        } else {
            integrationExample.presentApplePayComponent()
        }
    }

    internal func presentConvenienceStore() {
        if componentsView.isUsingSession {
            integrationExample.presentConvenienceStoreSession()
        } else {
            integrationExample.presentConvenienceStore()
        }
    }
    
    internal func requestInitialData() {
        integrationExample.requestInitialData()
    }

    // MARK: - Presenter

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        if let retryHandler = retryHandler {
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
    
    private func onConfigurationClosed(_ configuration: Configuration) {
        ConfigurationConstants.current = configuration
        dismiss(completion: nil)
        requestInitialData()
    }
    
}
