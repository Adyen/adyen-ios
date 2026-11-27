//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The size of corner rounding.
@_spi(AdyenInternal) public enum CornerRounding {

    /// No rounding.
    case none
    
    /// The fixed radius of corners in display points.
    case fixed(CGFloat)
    
    /// The corner radius value.
    package var radius: CGFloat {
        switch self {
        case .none:
            return 0
        case let .fixed(value):
            return value
        }
    }
    
}

@_spi(AdyenInternal)
extension CornerRounding: Equatable {
    
    public static func == (lhs: CornerRounding, rhs: CornerRounding) -> Bool {
        switch (lhs, rhs) {
        case let (.fixed(lhsValue), .fixed(rhsValue)):
            return lhsValue == rhsValue
        case (.none, .none):
            return true
        default:
            return false
        }
    }
    
}
