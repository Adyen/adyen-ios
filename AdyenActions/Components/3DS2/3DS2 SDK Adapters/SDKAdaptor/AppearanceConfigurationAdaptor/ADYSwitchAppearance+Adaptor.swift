//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift
import UIKit

extension ADYSwitchAppearance {
    internal var switchAppearance: SwitchAppearance {
        SwitchAppearance(
            font: font,
            textColor: textColor,
            switchTintColor: switchTintColor
        )
    }
}
