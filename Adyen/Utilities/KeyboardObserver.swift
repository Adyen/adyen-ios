//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Observe changes to the keyboard frames to update the UI accordingly
@_spi(AdyenInternal)
public class KeyboardObserver {
    
    /// The observable keyboard rect
    @AdyenObservable(CGRect.zero)
    public private(set) var keyboardRect: CGRect
    
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
        
        guard let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return self.keyboardRect = .zero
        }
        
        self.keyboardRect = bounds.intersection(UIScreen.main.bounds)
    }
}
