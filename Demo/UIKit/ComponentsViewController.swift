//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

    
internal final class ComponentsViewController: UIViewController {
    private lazy var componentsView = ComponentsView()

    private lazy var model: ComponentsModel = {
        let model = ComponentsModel()
        model.presenter = self
        return model
    }()

    internal lazy var items: [[ComponentItem]] = [
        [
            ComponentItem(title: "Drop In", present: model.dropInIntegration.DropIn)
        ],
        [
            ComponentItem(title: "Card", present: model.componentIntegration.Card),
            ComponentItem(title: "ApplePay", present: model.componentIntegration.ApplePay),
            ComponentItem(title: "iDEAL", present: model.componentIntegration.Ideal),
            ComponentItem(title: "SEPA Direct Debit", present: model.componentIntegration.SEPADirectDebit),
            ComponentItem(title: "MB WAY", present: model.componentIntegration.MBWay)
        ]
    ]
    
    // MARK: - View
    
    override internal func loadView() {
        view = componentsView
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Components"

        componentsView.items = items
        model.requestPaymentMethods()
    }

}

extension ComponentsViewController: Presenter {

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)

        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }

        adyen.present(alertController, animated: true)
    }

    internal func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        adyen.present(alertController, animated: true)
    }

    internal func present(viewController: UIViewController, completion: (() -> Void)?) {
        present(viewController, animated: true, completion: completion)
    }

    internal func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}
