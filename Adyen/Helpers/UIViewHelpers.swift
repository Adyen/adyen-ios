//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: UIView {

    public func snapShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.bounds.size, false, 0.0)
        base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    public func getTopMostView<T: UIView>() -> T? {
        if let foundView = base as? T {
            return foundView
        }

        var queue = [UIView]()
        queue.append(contentsOf: base.subviews)

        while !queue.isEmpty {
            let currentView = queue.removeFirst()
            if let foundView = currentView as? T {
                return foundView
            } else {
                queue.append(contentsOf: currentView.subviews)
            }
        }
        return nil
    }
}
