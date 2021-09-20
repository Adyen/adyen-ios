//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

private enum AssociatedKeys {
    internal static var animations = "animations"
}

/// :nodoc:
public class AnimationContext: NSObject {
    fileprivate let animationKey: String
    
    fileprivate let duration: TimeInterval
    
    fileprivate let delay: TimeInterval
    
    fileprivate let options: UIView.AnimationOptions
    
    fileprivate let animations: () -> Void
    
    fileprivate let completion: ((Bool) -> Void)?
    
    /// :nodoc:
    public init(animationKey: String,
                duration: TimeInterval,
                delay: TimeInterval = 0,
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

/// :nodoc:
public final class KeyFrameAnimationContext: AnimationContext {
    
    fileprivate let keyFrameOptions: UIView.KeyframeAnimationOptions
    
    /// :nodoc:
    public init(animationKey: String,
                duration: TimeInterval,
                delay: TimeInterval = 0,
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

/// :nodoc:
public final class SpringAnimationContext: AnimationContext {

    fileprivate let dampingRatio: CGFloat
    fileprivate let velocity: CGFloat

    /// :nodoc:
    public init(animationKey: String,
                duration: TimeInterval,
                delay: TimeInterval = 0,
                dampingRatio: CGFloat,
                velocity: CGFloat,
                options: UIView.AnimationOptions = [],
                animations: @escaping () -> Void,
                completion: ((Bool) -> Void)? = nil) {
        self.dampingRatio = dampingRatio
        self.velocity = velocity
        super.init(animationKey: animationKey,
                   duration: duration,
                   delay: delay,
                   options: options,
                   animations: animations,
                   completion: completion)
    }
}

extension AdyenScope where Base: UIView {
    /// :nodoc:
    public func animate(context: AnimationContext) {
        base.animations.append(context)
        
        if base.animations.count == 1 {
            animateNext(context: context)
        }
    }
    
    private func animateNext(context: AnimationContext) {
        let completion: (Bool) -> Void = {
            context.completion?($0)
            base.animations.removeFirst()
            base.animations.first.map(animateNext)
        }

        if let springContext = context as? SpringAnimationContext {
            UIView.animate(withDuration: context.duration,
                           delay: context.delay,
                           usingSpringWithDamping: springContext.dampingRatio,
                           initialSpringVelocity: springContext.velocity,
                           options: context.options,
                           animations: context.animations,
                           completion: completion)
        } else if let keyFrameContext = context as? KeyFrameAnimationContext {
            UIView.animateKeyframes(withDuration: keyFrameContext.duration,
                                    delay: keyFrameContext.delay,
                                    options: keyFrameContext.keyFrameOptions,
                                    animations: keyFrameContext.animations,
                                    completion: completion)
        } else {
            UIView.animate(withDuration: context.duration,
                           delay: context.delay,
                           options: context.options,
                           animations: context.animations,
                           completion: completion)
        }
    }
}

private extension UIView {
    /// :nodoc:
    var animations: [AnimationContext] {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.animations) as? [AnimationContext] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.animations, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}
