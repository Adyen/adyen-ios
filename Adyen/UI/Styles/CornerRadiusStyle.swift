//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The size of corner rounding.
public enum CornerRounding {
    
    /// No rounding.
    case none
    
    /// The fixed radius of corners in display points.
    case fixed(CGFloat)
    
    /// The radius of corners in percent of length of smallest dimension (width or height).
    /// Value should be in range of 0 to 0,5. Negative and exceeding positive values will be rounded to 0 or 0,5 accordingly.
    case percent(CGFloat)
    
}

extension CornerRounding: Equatable {
    
    /// :nodoc:
    public static func == (lhs: CornerRounding, rhs: CornerRounding) -> Bool {
        switch (lhs, rhs) {
        case let (.fixed(lhsValue), .fixed(rhsValue)):
            return lhsValue == rhsValue
        case let (.percent(lhsValue), .percent(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
    
}
