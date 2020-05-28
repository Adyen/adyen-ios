//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class DropInNavigationController: UINavigationController {
    
    internal typealias CancelHandler = (Bool, PaymentComponent?) -> Void
    
    private let cancelHandler: CancelHandler?
    
    /// Root container allows root of navigation controller to have a flexible size.
    /// Should be cleaned, as soon as next controller is presented.
    private var rootContainer: UIViewController?
    private var keyboardRect: CGRect = .zero
    
    internal let style: NavigationStyle
    
    internal init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: nil)
        setup(root: rootComponent)
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
        rootContainer = nil
        pushViewController(wrapInModalController(component: component), animated: true)
    }
    
    internal func present(root component: PresentableComponent) {
        let modal = wrapInModalController(component: component)
        modal.isRoot = true
        rootContainer = nil
        pushViewController(modal, animated: true)
    }
    
    internal func dismiss(completion: (() -> Void)? = nil) {
        popViewController(animated: true)
        completion?()
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard
            let topViewController = topViewController as? ModalViewController,
            topViewController.requiresInput,
            let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        keyboardRect = bounds.intersection(view.frame)
        updateFrame(for: topViewController)
    }
    
    @objc private func viewDidChangeFrame(_ notification: NSNotification) {
        guard let topViewController = topViewController else { return }
        updateFrame(for: topViewController)
    }
    
    // MARK: - Private
    
    private func wrapInModalController(component: PresentableComponent) -> ModalViewController {
        ModalViewController(rootViewController: component.viewController,
                            style: style) { [weak self] modal in
            self?.cancelHandler?(modal, component as? PaymentComponent)
        }
    }
    
    internal func updateFrame(for viewController: UIViewController) {
        if let modalViewController = rootContainer?.children.first {
            updateFrameOnUIThread(for: modalViewController)
        } else {
            updateFrameOnUIThread(for: viewController)
        }
    }
    
    private func updateFrameOnUIThread(for viewController: UIViewController) {
        guard let window = UIApplication.shared.keyWindow, let view = viewController.viewIfLoaded else { return }
        
        let frame = viewController.finalPresentationFrame(in: window, keyboardRect: self.keyboardRect)
        UIView.animate(withDuration: 0.25) { view.frame = frame }
    }
    
    private func setup(root component: PresentableComponent) {
        let rootContainer = UIViewController()
        viewControllers = [rootContainer]
        self.rootContainer = rootContainer
        
        let modal = wrapInModalController(component: component)
        modal.isRoot = true
        rootContainer.addChild(modal)
        rootContainer.view.addSubview(modal.view)
        updateFrame(for: modal)
        modal.didMove(toParent: rootContainer)
        
        delegate = self
        modalPresentationStyle = .custom
        transitioningDelegate = self
        navigationBar.isHidden = true
        
        let selector = #selector(keyboardWillChangeFrame(_:))
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
}

extension DropInNavigationController: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController,
                                       didShow viewController: UIViewController,
                                       animated: Bool) {
        updateFrame(for: viewController)
    }
    
    internal func navigationController(_ navigationController: UINavigationController,
                                       animationControllerFor operation: UINavigationController.Operation,
                                       from fromVC: UIViewController,
                                       to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(duration: 0.5)
    }
}

extension DropInNavigationController: UIViewControllerTransitioningDelegate {
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
