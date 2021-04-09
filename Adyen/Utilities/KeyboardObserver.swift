//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
public protocol KeyboardObserver: AnyObject {

    /// :nodoc:
    func startObserving()

    /// :nodoc:
    func stopObserving()

    /// :nodoc:
    var keyboardObserver: Any? { get set }
}

/// :nodoc:
extension KeyboardObserver {

    /// :nodoc:
    public func startObserving(_ observer: @escaping (_ keyboardRect: CGRect) -> Void) {
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        keyboardObserver = NotificationCenter.default.addObserver(forName: notificationName,
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
    public func stopObserving() {
        keyboardObserver.map(NotificationCenter.default.removeObserver)
        keyboardObserver = nil
    }
}
