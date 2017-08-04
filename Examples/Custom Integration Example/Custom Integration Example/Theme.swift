//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

struct Theme {
    
    static var primaryColor: UIColor {
        return UIColor(colorLiteralRed: 104.0 / 255, green: 207.0 / 255, blue: 184.0 / 255, alpha: 1.0)
    }
    
    static var secondaryColor: UIColor {
        return UIColor(colorLiteralRed: 129.0 / 255, green: 129.0 / 255, blue: 129.0 / 255, alpha: 1.0)
    }
    
    static var errorColor: UIColor {
        return UIColor(colorLiteralRed: 243.0 / 255, green: 165.0 / 255, blue: 54.0 / 255, alpha: 1.0)
    }
    
    static var headerFooterBackgroundColor: UIColor {
        return UIColor(colorLiteralRed: 246.0 / 255, green: 246.0 / 255, blue: 247.0 / 255, alpha: 1.0)
    }
    
    static var standardTextColor: UIColor {
        return UIColor(colorLiteralRed: 98.0 / 255, green: 98.0 / 255, blue: 98.0 / 255, alpha: 1.0)
    }
    
    static var standardFontRegular: UIFont? {
        return UIFont.systemFont(ofSize: 19.0, weight: UIFontWeightLight)
    }
    
    static var standardFontSmall: UIFont? {
        return UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightLight)
    }
    
    static var textFieldFont: UIFont? {
        return UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
    }
    
    static var headerFooterHeight: CGFloat {
        return 70.0
    }
    
    static var buttonHeight: CGFloat {
        return 50.0
    }
    
    static var buttonMargin: CGFloat {
        return 28.0
    }
    
}
