//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol DropInNavigationLayouter: AnyObject {
    func freezeFrameUpdate()
    
    func unfreezeFrameUpdate()
    
    func updateTopViewControllerIfNeeded(animated: Bool)
}

internal final class DropInNavigationController: UIViewController,
    DropInNavigationLayouter,
    KeyboardObserver,
    PreferredContentSizeConsumer {
    
    private let cancelHandler: CancelHandler?
    
    private var keyboardRect: CGRect = .zero
    
    private let rootNavigationController: ComponentNavigationController
    
    internal let chileViewController: HalfPageViewController
    
    internal typealias CancelHandler = (Bool, PresentableComponent) -> Void
    
    private let style: NavigationStyle
    
    // MARK: - Initializers
    
    internal init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        self.rootNavigationController = ComponentNavigationController(rootComponent: rootComponent, cancelHandler: cancelHandler)
        self.chileViewController = HalfPageViewController(child: rootNavigationController)
        super.init(nibName: nil, bundle: nil)
        setupChildViewController()
        startObserving()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Observing keyboard
    
    internal var keyboardObserver: Any?
    
    deinit {
        stopObserving()
    }

    internal func startObserving() {
        startObserving { [weak self] in
            self?.update(newKeyboardRect: $0)
        }
    }
    
    private func update(newKeyboardRect: CGRect) {
        keyboardRect = newKeyboardRect
        updateTopViewControllerIfNeeded()
    }
    
    // MARK: - Life cycle
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        rootNavigationController.view.backgroundColor = style.backgroundColor
    }
    
    // MARK: - Navigation
    
    internal func present(asModal component: PresentableComponent) {
        if component.requiresModalPresentation {
            rootNavigationController.push(component: component, animated: true)
        } else {
            present(component.viewController, animated: true, completion: nil)
        }
    }
    
    internal func present(root component: PresentableComponent) {
        rootNavigationController.push(component: component, animated: true)
    }
    
    @discardableResult
    internal func popViewController(animated: Bool) -> UIViewController? {
        rootNavigationController.popComponent(animated: animated)
    }
    
    // MARK: - Layout
    
    internal func freezeFrameUpdate() {
        chileViewController.freezeFrameUpdate()
    }
    
    internal func unfreezeFrameUpdate() {
        chileViewController.unfreezeFrameUpdate()
    }
    
    internal func willUpdatePreferredContentSize() { /* Empty implementation */ }

    internal func didUpdatePreferredContentSize() {
        updateTopViewControllerIfNeeded()
    }

    internal func updateTopViewControllerIfNeeded(animated: Bool = true) {
        let frame = chileViewController.requiresKeyboardInput ? self.keyboardRect : .zero
        chileViewController.updateFrame(keyboardRect: frame, animated: animated)
    }
    
    // MARK: - Private
    
    private func setupChildViewController() {
        addChild(chileViewController)
        view.addSubview(chileViewController.view)
        chileViewController.didMove(toParent: self)
        chileViewController.view.adyen.anchor(inside: view)
        
        rootNavigationController.delegate = self
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
}

extension DropInNavigationController: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController,
                                       animationControllerFor operation: UINavigationController.Operation,
                                       from fromVC: UIViewController,
                                       to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        /// Animation is the exact opposite when the language is RTL vs LTR.
        let isLTRInterface = view.effectiveUserInterfaceLayoutDirection == .leftToRight
        let isPush = isLTRInterface ? operation == .push : operation == .pop
        return DropInNavigationAnimator(duration: 0.6,
                                        isPush: isPush,
                                        dropInNavigationLayouter: self)
    }
    
}

extension DropInNavigationController: UIViewControllerTransitioningDelegate {

    internal func presentationController(forPresented presented: UIViewController,
                                         presenting: UIViewController?,
                                         source: UIViewController) -> UIPresentationController? {
        OverlayPresentationController(
            presented: presented,
            presenting: presenting,
            layoutDidChanged: { [weak self] in
                self?.updateTopViewControllerIfNeeded(animated: false)
            }
        )
    }
    
}
