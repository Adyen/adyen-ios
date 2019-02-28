//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public extension UIFont {
    
    func scaledFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont? {
        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: self)
        } else if #available(iOS 10.0, *) {
            let defaultTraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
            let defaultBodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: defaultTraitCollection)
            let fontSizeAdjustment = self.pointSize - defaultBodyFontDescriptor.pointSize
            let fontSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).pointSize + fontSizeAdjustment
            
            let scaledFont = self.withSize(fontSize)
            return scaledFont
        } else {
            return nil
        }
    }
    
}
