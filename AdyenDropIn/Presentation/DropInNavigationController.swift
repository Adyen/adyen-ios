//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

final class DropInNavigationController: UINavigationController, PreferredContentSizeConsumer, AdyenObserver {
    
    typealias CancelHandler = (Bool, PresentableComponent) -> Void
    
    private let cancelHandler: CancelHandler?
    
    let style: NavigationStyle
    
    lazy var keyboardObserver = KeyboardObserver()
    
    init(rootComponent: PresentableComponent, style: NavigationStyle, cancelHandler: @escaping CancelHandler) {
        self.style = style
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: Bundle(for: DropInNavigationController.self))
        setup(root: rootComponent)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observe(keyboardObserver.$keyboardRect) { [weak self] _ in
            self?.updateTopViewControllerIfNeeded()
        }
    }

    func willUpdatePreferredContentSize() { /* Empty implementation */ }

    func didUpdatePreferredContentSize() {
        updateTopViewControllerIfNeeded()
    }
    
    func present(asModal component: PresentableComponent) {
        if component.requiresModalPresentation {
            pushViewController(wrapInModalController(component: component,
                                                     isRoot: false),
                               animated: true)
        } else {
            present(component.viewController, animated: true, completion: nil)
        }
    }
    
    func present(root component: PresentableComponent) {
        pushViewController(wrapInModalController(component: component, isRoot: true), animated: true)
    }

    // MARK: - Private

    func updateTopViewControllerIfNeeded(animated: Bool = true) {
        guard let topViewController = topViewController as? WrapperViewController else { return }

        let frame = topViewController.requiresKeyboardInput ? keyboardObserver.keyboardRect : .zero
        topViewController.updateFrame(keyboardRect: frame, animated: animated)
    }
    
    private func wrapInModalController(component: PresentableComponent, isRoot: Bool) -> WrapperViewController {
        let modal = ModalViewController(
            rootViewController: component.viewController,
            style: style,
            navBarType: component.navBarType,
            cancelButtonHandler: { [weak self] in self?.cancelHandler?($0, component) }
        )
        modal.isRoot = isRoot
        let container = WrapperViewController(child: modal)
        
        return container
    }
    
    private func setup(root component: PresentableComponent) {
        let rootContainer = wrapInModalController(component: component, isRoot: true)
        viewControllers = [rootContainer]
        
        delegate = self
        modalPresentationStyle = .custom
        transitioningDelegate = self
        navigationBar.isHidden = true
    }
}

extension DropInNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SlideInPresentationAnimator(duration: 0.6)
    }
    
}

extension DropInNavigationController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        DimmingPresentationController(presented: presented,
                                      presenting: presenting,
                                      layoutDidChanged: { [weak self] in
                                          self?.updateTopViewControllerIfNeeded(animated: false)
                                      })
    }
    
}
