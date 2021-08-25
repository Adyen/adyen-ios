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

/// :nodoc:
public final class KeyFrameAnimationContext: AnimationContext {
    
    fileprivate let keyFrameOptions: UIView.KeyframeAnimationOptions
    
    /// :nodoc:
    public init(animationKey: String,
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

extension AdyenScope where Base: UIView {
    /// :nodoc:
    public func animate(context: AnimationContext) {
        base.animations.append(context)
        
        guard base.animations.count == 1 else { return }
        animateNext(context: context)
    }
    
    /// :nodoc:
    public func animateKeyframes(context: KeyFrameAnimationContext) {
        animate(context: context)
    }
    
    private func animateNext(context: AnimationContext?) {
        if let context = context as? KeyFrameAnimationContext {
            animateNextKeyframes(context: context)
            return
        }
        guard let context = context else { return }
        
        func next() {
            base.animations.removeFirst()
            animateNext(context: base.animations.first)
        }
        
        UIView.animate(withDuration: context.duration,
                       delay: context.delay,
                       options: context.options,
                       animations: context.animations,
                       completion: {
                           context.completion?($0)
                           next()
                       })
    }
    
    private func animateNextKeyframes(context: KeyFrameAnimationContext?) {
        guard let context = context else { return }
        
        func next() {
            base.animations.removeFirst()
            animateNext(context: base.animations.first)
        }
        
        UIView.animateKeyframes(withDuration: context.duration,
                                delay: context.delay,
                                options: context.keyFrameOptions,
                                animations: context.animations,
                                completion: {
                                    context.completion?($0)
                                    next()
                                })
    }
}

private extension UIView {
    /// :nodoc:
    var animations: [AnimationContext] {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.animations) as? [AnimationContext] else {
                return [AnimationContext]()
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.animations, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
}
