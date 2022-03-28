//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol DropInNavigationLayouter: AnyObject {
    func pauseFrameUpdate()
    
    func resumeFrameUpdate()
    
    func updateTopViewControllerIfNeeded(animated: Bool)
}

internal final class DropInNavigationController: UIViewController,
    DropInNavigationLayouter,
    KeyboardObserver,
    PreferredContentSizeConsumer {
    
    private let cancelHandler: CancelHandler?
    
    private var keyboardRect: CGRect = .zero
    
    private let rootNavigationController: ComponentNavigationController
    
    internal let childViewController: HalfPageViewController
    
    internal typealias CancelHandler = (Bool, PresentableComponent) -> Void
    
    private let style: NavigationStyle
    
    // MARK: - Initializers
    
    internal init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        self.rootNavigationController = ComponentNavigationController(rootComponent: rootComponent,
                                                                      style: style,
                                                                      cancelHandler: cancelHandler)
        self.childViewController = HalfPageViewController(child: rootNavigationController)
        super.init(nibName: nil, bundle: nil)
        setupChildViewController()
        setupNavigationBarAppearance()
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
        adyenPrint("keyboardRect: \(self.keyboardRect)")
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
        rootNavigationController.pushAsRoot(component: component, animated: true)
    }
    
    @discardableResult
    internal func popViewController(animated: Bool) -> UIViewController? {
        rootNavigationController.popComponent(animated: animated)
    }
    
    // MARK: - Layout
    
    internal func pauseFrameUpdate() {
        childViewController.pauseFrameUpdate()
    }
    
    internal func resumeFrameUpdate() {
        childViewController.resumeFrameUpdate()
    }
    
    internal func willUpdatePreferredContentSize() { /* Empty implementation */ }

    internal func didUpdatePreferredContentSize() {
        updateTopViewControllerIfNeeded()
    }

    internal func updateTopViewControllerIfNeeded(animated: Bool = true) {
        let frame = childViewController.requiresKeyboardInput ? self.keyboardRect : .zero
        childViewController.updateFrame(keyboardRect: frame, animated: animated)
    }
    
    // MARK: - Private
    
    private func setupChildViewController() {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        childViewController.view.adyen.anchor(inside: view)
        
        rootNavigationController.delegate = self
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    private func setupNavigationBarAppearance() {
        rootNavigationController.navigationBar.isTranslucent = false
        rootNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        rootNavigationController.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = style.backgroundColor
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
}

extension DropInNavigationController: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController,
                                       animationControllerFor operation: UINavigationController.Operation,
                                       from fromVC: UIViewController,
                                       to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        /// Animation is the exact opposite when the language is RTL vs LTR.
        let isLTRInterface = view.effectiveUserInterfaceLayoutDirection == .leftToRight
        let isRightToLeftAnimation = isLTRInterface ? operation == .push : operation == .pop
        return DropInNavigationAnimator(duration: 0.5,
                                        isRightToLeftSlideAnimation: isRightToLeftAnimation,
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
