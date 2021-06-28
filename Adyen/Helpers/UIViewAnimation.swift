//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
extension AdyenScope where Base: UIView {
    
    /// :nodoc:
    internal func animate(animationKey: String,
                          withDuration duration: TimeInterval,
                          delay: TimeInterval,
                          options: UIView.AnimationOptions = [],
                          animations: @escaping () -> Void,
                          completion: ((Bool) -> Void)? = nil) {
        let context = AnimationContext(animationKey: animationKey,
                                       duration: duration,
                                       delay: delay,
                                       options: options,
                                       animations: animations,
                                       completion: completion)
        if base.animationsMap[animationKey] == true {
            base.perform(#selector(base.animate(context:)), with: context, afterDelay: 0.1)
            return
        }
        base.animate(context: context)
    }
    
    /// :nodoc:
    internal func animateKeyframes(animationKey: String,
                                   withDuration duration: TimeInterval,
                                   delay: TimeInterval,
                                   options: UIView.KeyframeAnimationOptions = [],
                                   animations: @escaping () -> Void,
                                   completion: ((Bool) -> Void)? = nil) {
        let context = KeyFrameAnimationContext(animationKey: animationKey,
                                               duration: duration,
                                               delay: delay,
                                               options: options,
                                               animations: animations,
                                               completion: completion)
        if base.animationsMap[animationKey] == true {
            base.perform(#selector(base.animateKeyframes(context:)), with: context, afterDelay: 0.1)
            return
        }
        base.animateKeyframes(context: context)
    }
    
}

private enum AssociatedKeys {
    internal static var animations = "animations"
}

private class AnimationContext: NSObject {
    fileprivate let animationKey: String
    
    fileprivate let duration: TimeInterval
    
    fileprivate let delay: TimeInterval
    
    fileprivate let options: UIView.AnimationOptions
    
    fileprivate let animations: () -> Void
    
    fileprivate let completion: ((Bool) -> Void)?
    
    fileprivate init(animationKey: String,
                     duration: TimeInterval,
                     delay: TimeInterval,
                     options: UIView.AnimationOptions = [],
                     animations: @escaping () -> Void,
                     completion: ((Bool) -> Void)? = nil) {
        self.animationKey = animationKey
        self.duration = duration
        self.delay = delay
        self.options = options
        self.animations = animations
        self.completion = completion
    }
}

private final class KeyFrameAnimationContext: AnimationContext {
    
    fileprivate let keyFrameOptions: UIView.KeyframeAnimationOptions
    
    fileprivate init(animationKey: String,
                     duration: TimeInterval,
                     delay: TimeInterval,
                     options: UIView.KeyframeAnimationOptions = [],
                     animations: @escaping () -> Void,
                     completion: ((Bool) -> Void)? = nil) {
        self.keyFrameOptions = options
        super.init(animationKey: animationKey,
                   duration: duration,
                   delay: delay,
                   options: [],
                   animations: animations,
                   completion: completion)
    }
}

extension UIView {
    @objc fileprivate func animate(context: AnimationContext) {
        animationsMap[context.animationKey] = true
        UIView.animate(withDuration: context.duration,
                       delay: context.delay,
                       options: context.options,
                       animations: context.animations,
                       completion: {
                        context.completion?($0)
                        self.animationsMap[context.animationKey] = false
                       })
    }
    
    @objc fileprivate func animateKeyframes(context: KeyFrameAnimationContext) {
        animationsMap[context.animationKey] = true
        
        UIView.animateKeyframes(withDuration: context.duration,
                                delay: context.delay,
                                options: context.keyFrameOptions,
                                animations: context.animations,
                                completion: {
                                    context.completion?($0)
                                    self.animationsMap[context.animationKey] = false
                                })
    }
    
    /// :nodoc:
    fileprivate var animationsMap: [String: Bool] {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.animations) as? [String: Bool] else {
                return [String: Bool]()
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.animations, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}
