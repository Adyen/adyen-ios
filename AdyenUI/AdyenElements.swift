//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package struct AdyenElements {
    package var buttons: AdyenButtonStyles = .default
    package var labels: AdyenLabelStyles = .default
    package var `switch`: AdyenSwitchStyle = .default
    package var textField: AdyenTextFieldStyle = .default

    package init(
        buttons: AdyenButtonStyles = .default,
        labels: AdyenLabelStyles = .default,
        switch: AdyenSwitchStyle = .default,
        textField: AdyenTextFieldStyle = .default
    ) {
        self.buttons = buttons
        self.labels = labels
        self.switch = `switch`
        self.textField = textField
    }

    package static let `default` = AdyenElements()
}
