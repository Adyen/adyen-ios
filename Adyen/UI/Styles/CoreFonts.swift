//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
extension UIFont {
    
    internal enum AdyenCore {
        
        internal static var barTitle: UIFont {
            #if os(visionOS)
                UIFont.preferredFont(forTextStyle: .title1).adyen.font(with: .semibold)
            #else
                UIFont.preferredFont(forTextStyle: .title3).adyen.font(with: .semibold)
            #endif
        }
        
    }
}
