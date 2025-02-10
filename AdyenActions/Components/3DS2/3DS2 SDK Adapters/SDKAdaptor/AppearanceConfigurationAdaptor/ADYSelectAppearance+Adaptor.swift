//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift
import UIKit

extension ADYSelectAppearance {
    @MainActor
    internal var selectAppearance: SelectAppearance {
        SelectAppearance(
            font: font,
            textColor: textColor,
            borderColor: borderColor,
            highlightedBackgroundColor: highlightedBackgroundColor,
            selectionIndicatorTintColor: selectionIndicatorTintColor
        )
    }
}
