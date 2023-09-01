//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

final class PaymentsViewModel: ObservableObject, Identifiable {

    private lazy var dropInExample: DropInExample = {
        let dropIn = DropInExample()
        dropIn.presenter = self
        return dropIn
    }()

    private lazy var dropInAdvancedFlowExample: DropInAdvancedFlowExample = {
        let dropInAdvancedFlow = DropInAdvancedFlowExample()
        dropInAdvancedFlow.presenter = self
        return dropInAdvancedFlow
    }()

    private lazy var cardComponentAdvancedFlowExample: CardComponentAdvancedFlowExample = {
        let cardComponentAdvancedFlow = CardComponentAdvancedFlowExample()
        cardComponentAdvancedFlow.presenter = self
        return cardComponentAdvancedFlow
    }()

    private lazy var cardComponentExample: CardComponentExample = {
        let cardComponentExample = CardComponentExample()
        cardComponentExample.presenter = self
        return cardComponentExample
    }()

    @Published var viewControllerToPresent: UIViewController?

    @Published var items = [[ComponentsItem]]()
    
    @Published private(set) var isLoading: Bool = false
    
    @Published var isUsingSession: Bool = true

    // MARK: - DropIn Component

    func presentDropInComponent() {
        if isUsingSession {
            dropInExample.start()
        } else {
            dropInAdvancedFlowExample.start()
        }
    }

    func presentCardComponent() {
        if isUsingSession {
            cardComponentExample.start()
        } else {
            cardComponentAdvancedFlowExample.start()
        }
    }

    // TODO: add for other PM

    func viewDidAppear() {
        items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent)
            ]
        ]
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
    
    private func onConfigurationClosed(_ configuration: DemoAppSettings) {
        ConfigurationConstants.current = configuration
        dismiss(completion: nil)
    }
}

extension PaymentsViewModel: PresenterExampleProtocol {
    
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

    func presentAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewControllerToPresent = alertController
    }
    
    func showLoadingIndicator() {
        isLoading = true
    }
    
    func hideLoadingIndicator() {
        isLoading = false
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
