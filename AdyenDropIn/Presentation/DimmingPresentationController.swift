//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - DimmingPresentationController

/// Presentation Controller that performe dimming view alongside presentation animation.
internal final class DimmingPresentationController: UIPresentationController {
    internal var layoutDidChanged: () -> Void
    
    internal init(presented: UIViewController, presenting: UIViewController?, layoutDidChanged: @escaping () -> Void) {
        self.layoutDidChanged = layoutDidChanged
        super.init(presentedViewController: presented, presenting: presenting)
    }
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.AdyenDropIn.dimmBackground
        dimmingView.alpha = 0.0
        
        return dimmingView
    }()
    
    private func attachDimmigView(to view: UIView) {
        view.insertSubview(dimmingView, at: 0)
        let constraints = [
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dimmingView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    internal override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        layoutDidChanged()
    }
    
    /// :nodoc:
    internal override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else { return }
        attachDimmigView(to: containerView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    /// :nodoc:
    internal override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
    
    /// :nodoc:
    internal override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
}
