//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// MARK: - DimmingPresentationController

/// Presentation Controller that performs dimming view alongside presentation animation.
internal final class DimmingPresentationController: UIPresentationController {
    internal var layoutDidChanged: () -> Void
    
    internal init(presented: UIViewController, presenting: UIViewController?, layoutDidChanged: @escaping () -> Void) {
        self.layoutDidChanged = layoutDidChanged
        super.init(presentedViewController: presented, presenting: presenting)
    }
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.Adyen.dimmBackground
        dimmingView.alpha = 0.0
        
        return dimmingView
    }()
    
    private func attachDimmigView(to view: UIView) {
        view.insertSubview(dimmingView, at: 0)
        dimmingView.adyen.anchor(inside: view)
    }
    
    override internal func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        layoutDidChanged()
    }
    
    override internal var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return super.frameOfPresentedViewInContainerView }
        return containerView.frame
    }
    
    /// :nodoc:
    override internal func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView else { return }
        attachDimmigView(to: containerView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    /// :nodoc:
    override internal func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
    
    /// :nodoc:
    override internal func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
}
