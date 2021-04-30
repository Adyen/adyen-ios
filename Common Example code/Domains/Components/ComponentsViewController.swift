//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ComponentsViewController: UIViewController, Presenter {
    
    private lazy var componentsView = ComponentsView()

    private lazy var controller: PaymentsController = {

        let controller = PaymentsController()
        controller.presenter = self

        return controller
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
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent),
                ComponentsItem(title: "MB WAY", selectionHandler: presentMBWayComponent)
            ],
            [
                ComponentsItem(title: "Apple Pay", selectionHandler: presentApplePayComponent)
            ]
        ]
        
        controller.requestPaymentMethods()
    }
    
    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        controller.presentDropInComponent()
    }

    internal func presentCardComponent() {
        controller.presentCardComponent()
    }

    internal func presentIdealComponent() {
        controller.presentIdealComponent()
    }

    internal func presentSEPADirectDebitComponent() {
        controller.presentSEPADirectDebitComponent()
    }

    internal func presentMBWayComponent() {
        controller.presentMBWayComponent()
    }

    internal func presentApplePayComponent() {
        controller.presentApplePayComponent()
    }

    internal func requestPaymentMethods() {
        controller.requestPaymentMethods()
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
        present(viewController, animated: true, completion: completion)
    }

    internal func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}
