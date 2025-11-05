//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import UIKit

extension AdyenButtonStyle: Equatable {
    public static func == (lhs: AdyenButtonStyle, rhs: AdyenButtonStyle) -> Bool {
        lhs.textColor == rhs.textColor && lhs.backgroundColor == rhs.backgroundColor
            && lhs.disabledTextColor == rhs.disabledTextColor
            && lhs.disabledBackgroundColor == rhs.disabledBackgroundColor
            && lhs.cornerRadius == rhs.cornerRadius
    }
}

extension AdyenLabelStyle: Equatable {
    public static func == (lhs: AdyenLabelStyle, rhs: AdyenLabelStyle) -> Bool {
        lhs.font == rhs.font && lhs.color == rhs.color && lhs.disabledColor == rhs.disabledColor
            && lhs.textAlignment == rhs.textAlignment
    }
}
