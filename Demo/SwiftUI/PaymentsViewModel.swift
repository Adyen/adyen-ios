//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

final class PaymentsViewModel: ObservableObject, Identifiable, Presenter {

    private lazy var integrationExample: IntegrationExample = {
        let integrationExample = IntegrationExample()
        integrationExample.presenter = self
        return integrationExample
    }()

    @Published var viewControllerToPresent: UIViewController?

    @Published var items = [[ComponentsItem]]()

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

    func presentMBWayComponent() {
        integrationExample.presentMBWayComponent()
    }

    func viewDidAppear() {
        items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
                ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent),
                ComponentsItem(title: "MB WAY", selectionHandler: presentMBWayComponent)
            ]
        ]
        integrationExample.requestPaymentMethods()
    }
    
    // MARK: - Configuration
    
    func presentConfiguration() {
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
    
    private func onConfigurationClosed(_ configuration: Configuration) {
        ConfigurationConstants.current = configuration
        dismiss(completion: nil)
        integrationExample.requestPaymentMethods()
    }

    // MARK: - Presenter

    func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }

        viewControllerToPresent = alertController
    }

    func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewControllerToPresent = alertController
    }

    func present(viewController: UIViewController, completion: (() -> Void)?) {
        viewControllerToPresent = viewController
        completion?()
    }

    func dismiss(completion: (() -> Void)?) {
        viewControllerToPresent = nil
        completion?()
    }
}
