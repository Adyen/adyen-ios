//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension UIFont {

    /// Get new instance of `UIFont` with the same familyName and pointSize, but specified weight.
    /// - Parameter weight: The desired font's weight.
    func font(with weight: UIFont.Weight) -> UIFont {
        var descriptor = self.fontDescriptor
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traits])
        return UIFont(descriptor: descriptor, size: self.pointSize)
    }
}
