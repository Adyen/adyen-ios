//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public struct KeyboardTransition: Equatable {
    
    public let keyboardRect: CGRect
    public let animationDuration: TimeInterval
    public let animationOptions: UIView.AnimationOptions
    
    public init(
        keyboardRect: CGRect = .zero,
        animationDuration: TimeInterval = 0.25,
        animationOptions: UIView.AnimationOptions = .curveEaseInOut
    ) {
        self.keyboardRect = keyboardRect
        self.animationDuration = animationDuration
        self.animationOptions = animationOptions
    }
}

/// Observe changes to the keyboard frames to update the UI accordingly
@_spi(AdyenInternal)
public class KeyboardObserver {
    
    /// The observable keyboard transition
    @AdyenObservable(.init())
    public private(set) var keyboardTransition: KeyboardTransition
    
    public init() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrameNotification),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc
    private func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        keyboardTransition = KeyboardTransition(notification: notification)
    }
}

private extension KeyboardTransition {
    
    init(notification: Notification) {
        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let animationCurveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
            ?? UIView.AnimationCurve.easeInOut.rawValue
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) ?? .easeInOut
        
        self.init(
            keyboardRect: Self.keyboardRect(from: notification),
            animationDuration: animationDuration,
            animationOptions: UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
        )
    }
    
    static func keyboardRect(from notification: Notification) -> CGRect {
        guard let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return .zero
        }
        
        return bounds.intersection(UIScreen.main.bounds)
    }
}
