//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

private enum AssociatedKeys {
    internal static var animations = "animations"
}

internal class AnimationContext: NSObject {
    fileprivate let animationKey: String
    
    fileprivate let duration: TimeInterval
    
    fileprivate let delay: TimeInterval
    
    fileprivate let options: UIView.AnimationOptions
    
    fileprivate let animations: () -> Void
    
    fileprivate let completion: ((Bool) -> Void)?
    
    internal init(animationKey: String,
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

internal final class KeyFrameAnimationContext: AnimationContext {
    
    fileprivate let keyFrameOptions: UIView.KeyframeAnimationOptions
    
    internal init(animationKey: String,
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
    
    /// :nodoc:
    @objc internal func animate(context: AnimationContext) {
        if animationsMap[context.animationKey] == true {
            perform(#selector(animate(context:)), with: context, afterDelay: 0.1)
            return
        }
        animateSynchronized(context: context)
    }
    
    /// :nodoc:
    @objc internal func animateKeyframes(context: KeyFrameAnimationContext) {
        if animationsMap[context.animationKey] == true {
            perform(#selector(animateKeyframes(context:)), with: context, afterDelay: 0.1)
            return
        }
        animateKeyframesSynchronized(context: context)
    }
    
    @objc private func animateSynchronized(context: AnimationContext) {
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
    
    @objc private func animateKeyframesSynchronized(context: KeyFrameAnimationContext) {
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
    private var animationsMap: [String: Bool] {
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
