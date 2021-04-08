//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
public protocol KeyboardObserver {

    /// :nodoc:
    func subscribeToKeyboardUpdates(_ observer: @escaping (_ keyboardRect: CGRect) -> Void) -> Any

    /// :nodoc:
    func removeObserver(_ observer: Any)
}

/// :nodoc:
extension KeyboardObserver {

    /// :nodoc:
    public func subscribeToKeyboardUpdates(_ observer: @escaping (_ keyboardRect: CGRect) -> Void) -> Any {
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        return NotificationCenter.default.addObserver(forName: notificationName,
                                                      object: nil,
                                                      queue: OperationQueue.main) { notification in
            var keyboardRect: CGRect = .zero
            if let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardRect = bounds.intersection(UIScreen.main.bounds)
            }
            observer(keyboardRect)
        }
    }

    /// :nodoc:
    public func removeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
