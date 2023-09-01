//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
extension UIFont {
    
    enum AdyenCore {
        
        static var barTitle: UIFont {
            UIFont.preferredFont(forTextStyle: .title3).adyen.font(with: .semibold)
        }
        
    }
}
