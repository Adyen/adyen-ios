//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// MARK: - OverlayPresentationController

/// Presentation Controller that performs dimming view alongside presentation animation.
internal final class OverlayPresentationController: UIPresentationController {
    internal var layoutDidChanged: () -> Void
    
    internal init(presented: UIViewController, presenting: UIViewController?, layoutDidChanged: @escaping () -> Void) {
        self.layoutDidChanged = layoutDidChanged
        super.init(presentedViewController: presented, presenting: presenting)
    }
    
    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.Adyen.overlayBackground
        overlayView.alpha = 0.0
        
        return overlayView
    }()
    
    private func attachOverlayView(to view: UIView) {
        view.insertSubview(overlayView, at: 0)
        overlayView.adyen.anchor(inside: view)
    }
    
    override internal func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        layoutDidChanged()
    }
    
    override internal var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return super.frameOfPresentedViewInContainerView }
        return containerView.frame
    }
    
    /// :nodoc:
    override internal func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else { return }
        attachOverlayView(to: containerView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlayView.alpha = 1.0
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
            self.overlayView.alpha = 0.0
        })
    }
}
