//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import AdyenDropIn
import SwiftUI

internal final class PaymentsViewModel: ObservableObject, Identifiable, Presenter {

    private lazy var controller: PaymentsController = {

        let controller = PaymentsController()
        controller.presenter = self

        return controller
    }()

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var interruptionPresentationContext = InterruptionPresentationContext()

    @Published internal var items = [[ComponentsItem]]()

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
        controller.requestPaymentMethods()
    }

    // MARK: - Presenter

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let primaryButton = Alert.Button.default(Text("Retry"), action: {
                retryHandler?()
            })
            let dismissButton = Alert.Button.default(Text("OK"), action: {})
            self.interruptionPresentationContext.alertItem.wrappedValue = AlertItem(title: Text("Error"),
                                                                                    message: Text(error.localizedDescription),
                                                                                    primaryButton: primaryButton,
                                                                                    dismissButton: dismissButton)
        }
    }

    internal func presentAlert(withTitle title: String) {
        DispatchQueue.main.async {
            let dismissButton = Alert.Button.default(Text("OK"), action: {})
            self.interruptionPresentationContext.alertItem.wrappedValue = AlertItem(title: Text(title),
                                                                                    message: nil,
                                                                                    primaryButton: nil,
                                                                                    dismissButton: dismissButton)
        }
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
