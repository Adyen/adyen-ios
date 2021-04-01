//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

extension UIFont {
    
    /// :nodoc:
    internal enum AdyenCore {
        
        internal static var barTitle: UIFont {
            UIFont.preferredFont(forTextStyle: .title3).adyen.font(with: .semibold)
        }
        
        internal static var largeTitle: UIFont {
            .systemFont(ofSize: 32.0, weight: .bold)
        }
        
    }
}
