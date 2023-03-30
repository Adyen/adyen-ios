//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

internal final class ComponentsViewController: UIViewController, PresenterExampleProtocol {
    
    private lazy var componentsView = ComponentsView()

    private lazy var dropIn: DropIn = {
        let dropIn = DropIn()
        dropIn.presenter = self
        return dropIn
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
            dropIn.presentDropInComponentSession()
        } else {
            // Todo: Advanced Flow
        }
    }

    internal func requestInitialData() {
        dropIn.requestInitialData()
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
