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
    var view: UIViewController { get }
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
    }

    // MARK: - Public

    internal var view: UIViewController {
        component.viewController
    }

    internal func didCancel() {
        cancelHandler?(isRoot)
    }
}
