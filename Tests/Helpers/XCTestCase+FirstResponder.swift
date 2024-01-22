//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest

extension XCTestCase {
    /// invokes endEditing on the view and waits until none of the subviews is first responder anymore
    func endEditing(for view: UIView) {
        guard view.firstResponder != nil else { return }
        view.endEditing(true)
        wait(until: view, at: \.firstResponder, is: nil)
    }
}

extension UIView {

    var firstResponder: UIView? {
        if self.isFirstResponder { return self }
        
        for subview in subviews {
            if let firstResponderSubview = subview.firstResponder {
                return firstResponderSubview
            }
        }
        
        return nil
    }
}
