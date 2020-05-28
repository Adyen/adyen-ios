//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIColor {
    
    // swiftlint:disable:next explicit_acl
    enum AdyenDropIn {
        
        internal static var dimmBackground: UIColor {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return UIColor(white: 0.0, alpha: 0.2)
            }
        }
        
    }
    
}
