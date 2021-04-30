//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCard)
    import AdyenCard
#endif
import UIKit

extension UIColor {
    
    internal enum AdyenDropIn {
        
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

        internal static var componentBackground: UIColor {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }

        internal static var componentSecondaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .darkGray
            }
        }
        
        internal static let defaultBlue = UIColor(hex: 0x007AFF)
        
    }
    
}
