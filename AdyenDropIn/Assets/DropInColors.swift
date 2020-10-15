//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCard
import UIKit

extension UIColor {
    
    enum AdyenDropIn {
        
        internal static var dimmBackground: UIColor {
            return componentSeparator
        }
        
        internal static var componentSeparator: UIColor {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return UIColor(white: 0.0, alpha: 0.2)
            }
        }
        
        internal static let defaultBlue = UIColor(hex: 0x007AFF)
        
    }
    
}
