//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Animate sequential slid in and out movement for transitioning controllers.
internal final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    
    internal init(duration: TimeInterval) {
        self.duration = duration
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toShow = transitionContext.viewController(forKey: .to) as? WrapperViewController,
              let toHide = transitionContext.viewController(forKey: .from) as? WrapperViewController else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toShow.view)
        toShow.view.frame.origin.y = containerView.bounds.height
        toShow.updateFrame(keyboardRect: .zero)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0.0,
                                options: [],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                                        toHide.view.frame.origin.y = containerView.bounds.height
                                    }
                                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                                        toShow.view.frame.origin.y = containerView.frame.origin.y
                                    }
                                },
                                completion: { finished in
                                    transitionContext.completeTransition(finished)
                                })
    }
}
