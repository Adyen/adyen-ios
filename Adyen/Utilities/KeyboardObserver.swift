//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Observe changes to the keyboard frames to update the UI accordingly
@_spi(AdyenInternal)
public class KeyboardObserver {
    
    private enum Constants {
        static let settleDelay: TimeInterval = 0.15
    }
    
    /// The observable keyboard rect
    @AdyenObservable(CGRect.zero)
    public private(set) var keyboardRect: CGRect

    private let throttler = Throttler(minimumDelay: Constants.settleDelay)
    
    public init() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrameNotification),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    /// Publishes a taller keyboard immediately, so the keyboard never covers content.
    /// A shorter or hidden keyboard is published only once no new frame arrives within `Constants.settleDelay`,
    /// because UIKit sends short-lived hide and partial frames while the device rotates or folds.
    @objc
    private func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        let visibleRect = visibleKeyboardRect(from: notification)
        guard visibleRect.height < keyboardRect.height else {
            throttler.cancel()
            keyboardRect = visibleRect
            return
        }

        throttler.throttle { [weak self] in
            self?.keyboardRect = visibleRect
        }
    }

    /// Clips the keyboard frame to the screen the keyboard appears on, which is not always `UIScreen.main`
    /// (for example, the inner display of a foldable iPhone).
    private func visibleKeyboardRect(from notification: Notification) -> CGRect {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return .zero
        }

        let screen = notification.object as? UIScreen ?? UIScreen.main
        let visibleRect = frame.intersection(screen.bounds)
        return visibleRect.isEmpty ? .zero : visibleRect
    }
}
