//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal final class PaymentsViewModel: ObservableObject, Identifiable, Presenter {

    private lazy var integrationExample: IntegrationExample = {
        let integrationExample = IntegrationExample()
        integrationExample.presenter = self
        return integrationExample
    }()

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var items = [[ComponentsItem]]()

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

    internal func viewDidAppear() {
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

        viewControllerToPresent = alertController
    }

    internal func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewControllerToPresent = alertController
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
