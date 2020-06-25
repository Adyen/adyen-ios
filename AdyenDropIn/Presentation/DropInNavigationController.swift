//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal final class DropInNavigationController: UINavigationController {
    
    internal typealias CancelHandler = (Bool, PaymentComponent?) -> Void
    
    private let cancelHandler: CancelHandler?
    
    private var keyboardRect: CGRect = .zero
    
    internal let style: NavigationStyle
    
    internal init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: nil)
        setup(root: rootComponent)
        subscribeToKeyboardUpdates()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func present(_ viewController: UIViewController, customPresentation: Bool = true) {
        if customPresentation {
            pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }
    
    internal func present(asModal component: PresentableComponent) {
        pushViewController(wrapInModalController(component: component, isRoot: false), animated: true)
    }
    
    internal func present(root component: PresentableComponent) {
        pushViewController(wrapInModalController(component: component, isRoot: true), animated: true)
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let topViewController = topViewController as? WrapperViewController,
            topViewController.requiresInput,
            let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        keyboardRect = bounds.intersection(UIScreen.main.bounds)
        updateFrame(for: topViewController)
    }
    
    // MARK: - Private
    
    private func wrapInModalController(component: PresentableComponent, isRoot: Bool) -> WrapperViewController {
        let modal = ModalViewController(rootViewController: component.viewController,
                                        style: style) { [weak self] modal in
            self?.cancelHandler?(modal, component as? PaymentComponent)
        }
        modal.isRoot = isRoot
        let container = WrapperViewController(child: modal)
        container.addChild(modal)
        container.view.addSubview(modal.view)
        modal.didMove(toParent: container)
        
        return container
    }
    
    internal func updateFrame(for viewController: UIViewController) {
        guard let viewController = viewController as? WrapperViewController else {
            return assertionFailure("Unexpected viewController type.")
        }
        updateFrameOnUIThread(for: viewController.child)
    }
    
    private func updateFrameOnUIThread(for viewController: UIViewController) {
        guard let view = viewController.viewIfLoaded, let window = UIApplication.shared.keyWindow else { return }
        view.frame = viewController.adyen.finalPresentationFrame(in: window, keyboardRect: self.keyboardRect)
    }
    
    private func setup(root component: PresentableComponent) {
        let rootContainer = wrapInModalController(component: component, isRoot: true)
        viewControllers = [rootContainer]
        
        delegate = self
        modalPresentationStyle = .custom
        transitioningDelegate = self
        navigationBar.isHidden = true
    }
    
    private func subscribeToKeyboardUpdates() {
        let selector = #selector(keyboardWillChangeFrame(_:))
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
}

extension DropInNavigationController: UINavigationControllerDelegate {
    
    /// :nodoc:
    internal func navigationController(_ navigationController: UINavigationController,
                                       animationControllerFor operation: UINavigationController.Operation,
                                       from fromVC: UIViewController,
                                       to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(duration: 0.5)
    }
    
}

extension DropInNavigationController: UIViewControllerTransitioningDelegate {
    
    /// :nodoc:
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presented: presented,
                                             presenting: presenting,
                                             layoutDidChanged: { [weak self] in
                                                 guard let self = self,
                                                     let viewController = self.topViewController
                                                 else { return }
                                                 self.updateFrame(for: viewController)
        })
    }
    
}

/// :nodoc:
internal final class WrapperViewController: UIViewController {
    
    /// :nodoc:
    internal lazy var requiresInput: Bool = heirarchyContainsAForm(viewController: child)
    
    /// :nodoc:
    internal let child: ModalViewController
    
    /// :nodoc:
    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func heirarchyContainsAForm(viewController: UIViewController?) -> Bool {
        if viewController is FormViewController {
            return true
        }
        
        return viewController?.children.contains(where: { heirarchyContainsAForm(viewController: $0) }) ?? false
    }
    
}
