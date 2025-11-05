//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import UIKit

extension AdyenButtonStyle: Equatable {
    public static func == (lhs: AdyenButtonStyle, rhs: AdyenButtonStyle) -> Bool {
        lhs.textColor == rhs.textColor &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.disabledTextColor == rhs.disabledTextColor &&
            lhs.disabledBackgroundColor == rhs.disabledBackgroundColor &&
            lhs.cornerRadius == rhs.cornerRadius
    }
}
