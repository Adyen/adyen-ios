//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest

extension XCTestCase {
    /// invokes endEditing on the view and waits until none of the subviews is first responder anymore
    @MainActor
    func endEditing(for view: UIView) {
        guard let responder = view.firstResponder else { return }
        responder.endEditing(true)
        let thresholdDate = Date().addingTimeInterval(60)
        while thresholdDate.timeIntervalSinceNow > 0, view.firstResponder != nil {
            wait(for: .milliseconds(100))
        }
        XCTAssertNil(view.firstResponder, "Expected no first responder after endEditing")
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
