//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A custom presentation controller that presents a view controller with a dynamic height.
internal final class DynamicHeightPresentationController: UIPresentationController {
    
    // MARK: - UIPresentationController
    
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            containerView.addSubview(dimmingView)
            let dimmingViewConstraints = [
                dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]
            NSLayoutConstraint.activate(dimmingViewConstraints)
        }
        
        dimmingView.alpha = 0.0
        animateAlongsideTransition {
            self.dimmingView.alpha = 1.0
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        animateAlongsideTransition {
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }
    
    internal override var frameOfPresentedViewInContainerView: CGRect {
        var contentSize = containerViewBounds.size
        if presentedViewController.preferredContentSize != CGSize.zero {
            contentSize.height = presentedViewController.preferredContentSize.height
        }
        
        var presentedFrame = CGRect.zero
        presentedFrame.size = contentSize
        presentedFrame.origin.y = containerViewBounds.maxY - presentedFrame.height
        
        return presentedFrame
    }
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard let presentedView = presentedView else {
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            presentedView.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
    }
    
    // MARK: - Private
    
    private var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var containerViewBounds: CGRect {
        return containerView?.bounds ?? .zero
    }
    
    private func animateAlongsideTransition(animations: @escaping () -> Void) {
        guard let coordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            animations()
        }, completion: nil)
    }
}
