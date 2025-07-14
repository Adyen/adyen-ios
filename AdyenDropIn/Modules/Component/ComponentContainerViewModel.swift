//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

internal protocol ComponentContainerViewModelProtocol {
    var componentViewController: UIViewController { get }
    var isRoot: Bool { get }
    func didCancel()
}

internal class ComponentContainerViewModel: ComponentContainerViewModelProtocol {

    // MARK: - Properties

    private let component: PresentableComponent
    internal let isRoot: Bool
    private let cancelHandler: ((_ isRoot: Bool) -> Void)?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        isRoot: Bool,
        cancelHandler: ((Bool) -> Void)?
    ) {
        self.component = component
        self.isRoot = isRoot
        self.cancelHandler = cancelHandler

        setupComponent()
    }

    // MARK: - Public

    internal var componentViewController: UIViewController {
        component.viewController
    }

    internal func didCancel() {
        cancelHandler?(isRoot)
    }

    // MARK: - Private

    private func setupComponent() {
        (component as? PaymentComponent)?.delegate = self
    }
}

// MARK: - PaymentComponentDelegate

extension ComponentContainerViewModel: PaymentComponentDelegate {

    func didSubmit(
        _ data: Adyen.PaymentComponentData,
        from component: any Adyen.PaymentComponent
    ) {
        // TODO: -
        print("SUBMIT")
    }
    
    func didFail(
        with error: any Error,
        from component: any Adyen.PaymentComponent
    ) {
        // TODO: -
    }
}
