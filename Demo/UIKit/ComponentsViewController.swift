//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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
                ComponentsItem(title: "ApplePay", selectionHandler: presentApplePayComponent),
                ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent),
                ComponentsItem(title: "MB WAY", selectionHandler: presentMBWayComponent)
            ]
        ]
        
        integrationExample.requestPaymentMethods()
    }
    
    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        integrationExample.presentDropInComponent()
    }

    internal func presentCardComponent() {
        integrationExample.presentCardComponent()
    }

    internal func presentIdealComponent() {
        integrationExample.presentIdealComponent()
    }

    internal func presentSEPADirectDebitComponent() {
        integrationExample.presentSEPADirectDebitComponent()
    }

    internal func presentMBWayComponent() {
        integrationExample.presentMBWayComponent()
    }

    internal func presentApplePayComponent() {
        integrationExample.presentApplePayComponent()
    }

    internal func requestPaymentMethods() {
        integrationExample.requestPaymentMethods()
    }

    // MARK: - Presenter

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }

        present(alertController, animated: true)
    }

    internal func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alertController, animated: true)
    }

    internal func present(viewController: UIViewController, completion: (() -> Void)?) {
        adyen.topPresenter.present(viewController, animated: true, completion: completion)
    }

    internal func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}
