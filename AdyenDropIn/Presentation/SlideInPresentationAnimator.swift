//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Animate sequential slid in and out movement for transitioning controllers.
internal final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private enum Animation: String {
        case dropinTransitionPresentation = "transition_presentation"
    }
    
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

        let showDistance = Double(toShow.child.view.bounds.height)
        let hideDistance = Double(toHide.child.view.bounds.height)
        let distance = showDistance + hideDistance

        let containerView = transitionContext.containerView
        containerView.addSubview(toShow.view)
        toShow.view.frame.origin.y = containerView.bounds.height
        toShow.updateFrame(keyboardRect: .zero)

        let context = KeyFrameAnimationContext(animationKey: Animation.dropinTransitionPresentation.rawValue,
                                               duration: duration,
                                               delay: 0.0,
                                               options: [.beginFromCurrentState],
                                               animations: {
                                                   UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                                      relativeDuration: hideDistance / distance) {
                                                       toHide.view.frame.origin.y = containerView.bounds.height
                                                   }
                                                   UIView.addKeyframe(withRelativeStartTime: hideDistance / distance,
                                                                      relativeDuration: showDistance / distance) {
                                                       toShow.view.frame.origin.y = containerView.frame.origin.y
                                                   }
                                               },
                                               completion: { finished in
                                                   transitionContext.completeTransition(finished)
                                               })
        containerView.adyen.animate(context: context)
    }
}
