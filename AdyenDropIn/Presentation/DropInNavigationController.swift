//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal final class DropInNavigationController: UINavigationController {

    internal typealias CancelHandler = (Bool, PresentableComponent) -> Void
    
    private let cancelHandler: CancelHandler?
    
    internal let style: NavigationStyle
    
    internal lazy var keyboardObserver = KeyboardObserver()

    // MARK: - Initializers

    internal init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: Bundle(for: DropInNavigationController.self))
        setup(root: rootComponent)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    internal func present(asModal component: PresentableComponent) {
        if component.requiresModalPresentation {
            pushViewController(
                wrapInComponentViewController(
                    component: component,
                    isRoot: false
                ),
                animated: true
            )
        } else {
            present(component.viewController, animated: true, completion: nil)
        }
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
    
    private func setup(root component: PresentableComponent) {
        let rootContainer = wrapInComponentViewController(component: component, isRoot: true)
        viewControllers = [rootContainer]
    }
}
