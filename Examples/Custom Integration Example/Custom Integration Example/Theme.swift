//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

struct Theme {
    static var primaryColor: UIColor {
        return #colorLiteral(red: 0.4078431373, green: 0.8117647059, blue: 0.7215686275, alpha: 1)
    }
    
    static var secondaryColor: UIColor {
        return #colorLiteral(red: 0.5058823529, green: 0.5058823529, blue: 0.5058823529, alpha: 1)
    }
    
    static var errorColor: UIColor {
        return #colorLiteral(red: 0.9529411765, green: 0.6470588235, blue: 0.2117647059, alpha: 1)
    }
    
    static var headerFooterBackgroundColor: UIColor {
        return #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
    }
    
    static var standardTextColor: UIColor {
        return #colorLiteral(red: 0.3843137255, green: 0.3843137255, blue: 0.3843137255, alpha: 1)
    }
    
    static var standardFontRegular: UIFont? {
        return UIFont.systemFont(ofSize: 19.0, weight: .light)
    }
    
    static var standardFontSmall: UIFont? {
        return UIFont.systemFont(ofSize: 14.0, weight: .light)
    }
    
    static var textFieldFont: UIFont? {
        return UIFont.systemFont(ofSize: 16.0, weight: .light)
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
