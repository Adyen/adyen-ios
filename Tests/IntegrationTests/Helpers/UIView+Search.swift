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
    
    func findView<T: UIView>(by lastAccessibilityIdentifierComponent: String) -> T? {
        if self.accessibilityIdentifier?.hasSuffix(lastAccessibilityIdentifierComponent) == true {
            return self as? T
        }
        
        for subview in subviews {
            if let v = subview.findView(by: lastAccessibilityIdentifierComponent) {
                return v as? T
            }
        }
        
        return nil
    }

    func findAllViews<T: UIView>(with accessibilityIdentifier: String) -> [T] {
        var results: [T] = []
        if self.accessibilityIdentifier == accessibilityIdentifier, let view = self as? T {
            results.append(view)
        }
        for subview in subviews {
            let subviewResults: [T] = subview.findAllViews(with: accessibilityIdentifier)
            results.append(contentsOf: subviewResults)
        }
        return results
    }

    func findAllViews<T: UIView>(by lastAccessibilityIdentifierComponent: String) -> [T] {
        var results: [T] = []
        if self.accessibilityIdentifier?.hasSuffix(lastAccessibilityIdentifierComponent) == true, let view = self as? T {
            results.append(view)
        }
        for subview in subviews {
            let subviewResults: [T] = subview.findAllViews(by: lastAccessibilityIdentifierComponent)
            results.append(contentsOf: subviewResults)
        }
        return results
    }
}
