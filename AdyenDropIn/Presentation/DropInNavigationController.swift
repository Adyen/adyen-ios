//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI
import UIKit

internal final class DropInNavigationController: UINavigationController {

    // MARK: - Initializers

    internal typealias CancelHandler = (Bool, PresentableComponent) -> Void
    
    private let cancelHandler: CancelHandler?
    
    internal let style: NavigationStyle
    
    internal lazy var keyboardObserver = KeyboardObserver()

    // MARK: - Initializers

    internal init(
        rootViewController: UIViewController,
        style: NavigationStyle,
        cancelHandler: @escaping CancelHandler
    ) {
        self.style = style
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: Bundle(for: DropInNavigationController.self))

        viewControllers = [rootViewController]
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    internal func present(_ viewController: UIViewController) {
        pushViewController(viewController, animated: true)
    }
}
