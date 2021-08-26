//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Animate sequential slid in and out movement for transitioning controllers.
internal final class SlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private static let pixelPerSec: Double = 1800

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

        let distance = Double(toShow.child.view.bounds.height + toHide.child.view.bounds.height)
        let time = distance / SlideInPresentationAnimator.pixelPerSec
        let containerView = transitionContext.containerView
        containerView.addSubview(toShow.view)
        toShow.view.frame.origin.y = containerView.bounds.height
        toShow.updateFrame(keyboardRect: .zero)

        let context = KeyFrameAnimationContext(animationKey: Animation.dropinTransitionPresentation.rawValue,
                                               duration: time,
                                               delay: 0.0,
                                               options: [.layoutSubviews, .beginFromCurrentState],
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
        containerView.adyen.animate(context: context)

    }
}
