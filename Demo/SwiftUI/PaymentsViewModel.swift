//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal final class PaymentsViewModel: ObservableObject, Identifiable, PresenterExampleProtocol {

    private lazy var dropIn: DropInExample = {
        let dropIn = DropInExample()
        dropIn.presenter = self
        return dropIn
    }()

    @Published internal var viewControllerToPresent: UIViewController?

    @Published internal var items = [[ComponentsItem]]()

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
       // todo: add advanced flow
    }

   // TODO: add for other PM

    internal func viewDidAppear() {
        items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ]
        ]
        // todo: add request payment method api
    }
    
    // MARK: - Configuration
    
    internal func presentConfiguration() {
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
        // todo: add request payment method api
    }

    // MARK: - Presenter

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }

        viewControllerToPresent = alertController
    }

    internal func presentAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
