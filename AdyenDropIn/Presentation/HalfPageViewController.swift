//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class HalfPageViewController: UIViewController {

    // MARK: - Properties

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    
    internal var yOffset: CGFloat {
        get {
            topConstraint?.constant ?? 0.0
        }
        
        set {
            topConstraint?.constant = newValue
            child.viewIfLoaded?.layoutIfNeeded()
        }
    }

    internal var requiresKeyboardInput: Bool {
        child.topViewController?.adyen.hierarchyRequiresKeyboardInput() ?? false
    }

    internal let child: ComponentNavigationController

    // MARK: - Initializers

    internal init(child: ComponentNavigationController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
        setupChildViewController()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct FrameUpdateContext {
        internal let keyboardRect: CGRect
        
        internal let animated: Bool
    }
    
    private var isFrameUpdateFrozen: Bool = false
    
    /// Keep only the currently animating context and only one next context, i.e the latest.
    private var currentlyUpdatingFrameContext: FrameUpdateContext?
    private var nextUpdatingFrameContext: FrameUpdateContext?
    
    internal func freezeFrameUpdate() {
        isFrameUpdateFrozen = true
    }
    
    internal func unfreezeFrameUpdate() {
        let oldValue = isFrameUpdateFrozen
        isFrameUpdateFrozen = false
        
        if oldValue == true {
            /// Update the frame using the latest `nextUpdatingFrameContext` if there is any.
            updateNextFrameIfNeeded()
        }
    }
    
    private func updateNextFrameIfNeeded() {
        guard isUpdatingFrameAllowed(),
              let nextContext = nextUpdatingFrameContext else { return }
        
        nextUpdatingFrameContext = nil
        updateFrame(with: nextContext)
    }
    
    internal func updateFrame(keyboardRect: CGRect, animated: Bool = true) {
        let context = FrameUpdateContext(keyboardRect: keyboardRect,
                                         animated: animated)
        guard isUpdatingFrameAllowed() else {
            /// There is currently an ongoing animation or updating frames is frozen,
            /// in this case update the `nextUpdatingFrameContext`.
            nextUpdatingFrameContext = context
            return
        }
        updateFrame(with: context)
    }
    
    private func isUpdatingFrameAllowed() -> Bool {
        /// Frame updates are not allowed in case there is currently a frame update ongoing
        /// or frame updates are frozen.
        currentlyUpdatingFrameContext == nil &&
            isFrameUpdateFrozen == false &&
            isViewLoaded
    }

    private func updateFrame(with context: FrameUpdateContext) {
        guard let view = viewIfLoaded else { return }
        let finalFrame = child.finalPresentationFrame(with: context.keyboardRect)
        AdyenAssertion.assert(message: "isFrameUpdateFrozen must not be true",
                              condition: isFrameUpdateFrozen)
        AdyenAssertion.assert(message: "Only one animation at a time is allowed",
                              condition: currentlyUpdatingFrameContext != nil)
        currentlyUpdatingFrameContext = context
        view.layoutIfNeeded()
        view.adyen.animate(context: SpringAnimationContext(
            animationKey: "Update frame",
            duration: context.animated ? 0.4 : 0.0,
            delay: 0,
            dampingRatio: 0.8,
            velocity: 0.2,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak self] in
                self?.update(finalFrame: finalFrame)
            },
            completion: { [weak self] _ in
                self?.currentlyUpdatingFrameContext = nil
                self?.updateNextFrameIfNeeded()
            }
        ))
    }

    // MARK: - Private

    private func setupChildViewController() {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
        setupChildLayout()
    }
    
    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        child.view.adyen.round(using: .fixed(12))
    }

    private func setupChildLayout() {
        let childView: UIView = child.view
        childView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = childView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = childView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leftConstraint = childView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightConstraint = childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([leftConstraint,
                                     rightConstraint,
                                     bottomConstraint,
                                     topConstraint])

        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.leftConstraint = leftConstraint
        self.rightConstraint = rightConstraint
    }
    
    private func update(finalFrame: CGRect) {
        leftConstraint?.constant = finalFrame.origin.x
        rightConstraint?.constant = -finalFrame.origin.x
        topConstraint?.constant = finalFrame.origin.y
        viewIfLoaded?.layoutIfNeeded()
    }
}
