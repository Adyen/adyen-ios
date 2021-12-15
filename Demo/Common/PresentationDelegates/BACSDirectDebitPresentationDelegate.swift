//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenComponents
import Foundation

/// :nodoc:
internal class BACSDirectDebitPresentationDelegate: PresentationDelegate {

    // MARK: - Properties

    private let bacsComponent: BACSDirectDebitComponent

    private var navigationController: UINavigationController? {
        bacsComponent.viewController.navigationController
    }

    // MARK: - Initializers

    /// :nodoc:
    internal init(bacsComponent: BACSDirectDebitComponent) {
        self.bacsComponent = bacsComponent
    }

    /// :nodoc:
    internal func present(component: PresentableComponent) {
        let navigationItem = component.viewController.navigationItem
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationController?.pushViewController(component.viewController, animated: true)
    }

    // MARK: - Private

    @objc
    private func dismiss() {
        navigationController?.dismiss(animated: true)
    }
}
