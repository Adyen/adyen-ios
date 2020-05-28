//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Animate sequential slid in and out movement for transitioning controllers.
internal final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    
    internal init(duration: TimeInterval) {
        self.duration = duration
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toShow = transitionContext.viewController(forKey: .to),
            let toHide = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toShow.view)
        toShow.view.frame.origin.y = containerView.bounds.height
        
        let preferedFrame = toShow.finalPresentationFrame(in: containerView)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                toHide.view.frame.origin.y = containerView.bounds.height
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                toShow.view.frame = preferedFrame
            }
            
        }, completion: { finished in
            
            transitionContext.completeTransition(finished)
        })
    }
}
