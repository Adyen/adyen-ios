//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIView {
    func findView<T: UIView>(with accessibilityIdentifier: String) -> T? {
        if self.accessibilityIdentifier == accessibilityIdentifier {
            return self as? T
        }
        
        for subview in subviews {
            if let v = subview.findView(with: accessibilityIdentifier) {
                return v as? T
            }
        }
        
        return nil
    }
}
