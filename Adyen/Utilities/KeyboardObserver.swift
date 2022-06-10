//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public protocol KeyboardObserver: AnyObject {

    func startObserving()

    func stopObserving()

    var keyboardObserver: Any? { get set }
}

@_spi(AdyenInternal)
extension KeyboardObserver {

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

    public func stopObserving() {
        keyboardObserver.map(NotificationCenter.default.removeObserver)
        keyboardObserver = nil
    }
}
