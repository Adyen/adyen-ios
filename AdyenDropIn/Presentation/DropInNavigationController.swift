//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
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
        setup(root: rootViewController)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    internal func present(_ component: PresentableComponent) {
        let viewController = wrapInComponentViewController(component: component, isRoot: false)
        pushViewController(viewController, animated: true)
    }
    
    internal func present(root component: PresentableComponent) {
        pushViewController(
            wrapInComponentViewController(component: component, isRoot: true),
            animated: true
        )
    }

    // MARK: - Private
    
    private func wrapInComponentViewController(component: PresentableComponent, isRoot: Bool) -> UIViewController {
        let componentViewModel = ComponentViewModel(
            component: component,
            isRoot: isRoot
        ) { [weak self] isRoot in
            self?.cancelHandler?(isRoot, component)
        }
        let modalViewController = ComponentViewController(viewModel: componentViewModel)
        return modalViewController
    }
    
    private func setup(root viewController: UIViewController) {
        // TODO: - Only wrap if its a regular component.
        // let rootContainer = wrapInComponentViewController(component: component, isRoot: true)
        viewControllers = [viewController]
    }
}
