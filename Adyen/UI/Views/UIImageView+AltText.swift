//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
extension UIImageView {
    
    /// Prepares the image view for accessibility
    ///
    /// - Marks the view as `isAccessibilityElement`
    /// - Updates the `accessibilityValue`
    /// - Insets the `accessibilityTraits` value `.image`
    ///
    /// - Parameter altText: The string to be used as `accessibilityValue`
    public func updateAltText(_ altText: String) {
        isAccessibilityElement = true
        accessibilityValue = altText
        accessibilityTraits.insert(.image)
    }
}
