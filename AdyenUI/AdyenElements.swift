//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct AdyenElements {
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

    public static let `default` = AdyenElements()
}

public extension AdyenElements {
    func buttons(_ buttons: AdyenButtonStyles) -> Self {
        AdyenElements(
            buttons: buttons,
            labels: self.labels,
            switch: self.switch,
            textField: self.textField
        )
    }

    func labels(_ labels: AdyenLabelStyles) -> Self {
        AdyenElements(
            buttons: self.buttons,
            labels: labels,
            switch: self.switch,
            textField: self.textField
        )
    }

    func `switch`(_ switch: AdyenSwitchStyle) -> Self {
        AdyenElements(
            buttons: self.buttons,
            labels: self.labels,
            switch: `switch`,
            textField: self.textField
        )
    }

    func textField(_ textField: AdyenTextFieldStyle) -> Self {
        AdyenElements(
            buttons: self.buttons,
            labels: self.labels,
            switch: self.switch,
            textField: textField
        )
    }

}
