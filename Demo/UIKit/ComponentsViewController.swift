//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

final class ComponentsViewController: UIViewController, Presenter {
    
    private lazy var componentsView = ComponentsView()

    private lazy var integrationExample: IntegrationExample = {
        let integrationExample = IntegrationExample()
        integrationExample.presenter = self
        return integrationExample
    }()
    
    // MARK: - View
    
    override func loadView() {
        view = componentsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Components"
        
        componentsView.items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
                ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent),
                ComponentsItem(title: "BACS Direct Debit", selectionHandler: presentBACSDirectDebitComponent),
                ComponentsItem(title: "MB WAY", selectionHandler: presentMBWayComponent),
                ComponentsItem(title: "Convenience Stores", selectionHandler: presentConvenienceStore)
            ],
            [
                ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)
            ]
        ]
        
        requestPaymentMethods()
        
        if #available(iOS 13.0.0, *) {
            addConfigurationButton()
        }
    }
    
    // MARK: - DropIn Component

    func presentDropInComponent() {
        integrationExample.presentDropInComponent()
    }

    func presentCardComponent() {
        integrationExample.presentCardComponent()
    }

    func presentIdealComponent() {
        integrationExample.presentIdealComponent()
    }

    func presentSEPADirectDebitComponent() {
        integrationExample.presentSEPADirectDebitComponent()
    }

    func presentBACSDirectDebitComponent() {
        integrationExample.presentBACSDirectDebitComponent()
    }

    func presentMBWayComponent() {
        integrationExample.presentMBWayComponent()
    }

    func presentApplePayComponent() {
        integrationExample.presentApplePayComponent()
    }

    func requestPaymentMethods() {
        integrationExample.requestPaymentMethods()
    }

    func presentConvenienceStore() {
        integrationExample.presentConvenienceStore()
    }

    // MARK: - Presenter

    func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }

        present(viewController: alertController, completion: nil)
    }

    func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(viewController: alertController, completion: nil)
    }

    func present(viewController: UIViewController, completion: (() -> Void)?) {
        adyen.topPresenter.present(viewController, animated: true, completion: completion)
    }

    func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
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
        requestPaymentMethods()
    }
    
}
