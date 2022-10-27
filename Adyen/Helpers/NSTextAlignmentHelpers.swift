//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import QuartzCore
import UIKit

/// :nodoc:
extension NSTextAlignment: AdyenCompatible {}

/// :nodoc:
public extension AdyenScope where Base == NSTextAlignment {
    /// :nodoc:
    var caAlignmentMode: CATextLayerAlignmentMode {
        switch base {
        case .center:
            return .center
        case .justified:
            return .justified
        case .left:
            return .left
        case .right:
            return .right
        case .natural:
            return .natural
        default:
            return .center
        }
    }
}
