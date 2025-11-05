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

extension AdyenButtonStyles: Equatable {
    public static func == (lhs: AdyenButtonStyles, rhs: AdyenButtonStyles) -> Bool {
        lhs.primary == rhs.primary &&
            lhs.secondary == rhs.secondary &&
            lhs.tertiary == rhs.tertiary &&
            lhs.destructive == rhs.destructive
    }
}

extension AdyenLabelStyles: Equatable {
    public static func == (lhs: AdyenLabelStyles, rhs: AdyenLabelStyles) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.body == rhs.body &&
            lhs.bodyEmphasized == rhs.bodyEmphasized &&
            lhs.subheadline == rhs.subheadline &&
            lhs.subheadlineEmphasized == rhs.subheadlineEmphasized &&
            lhs.footnote == rhs.footnote &&
            lhs.footnoteEmphasized == rhs.footnoteEmphasized
    }
}

extension AdyenSwitchStyle: Equatable {
    public static func == (lhs: AdyenSwitchStyle, rhs: AdyenSwitchStyle) -> Bool {
        lhs.backgroundColor == rhs.backgroundColor &&
            lhs.tintColor == rhs.tintColor &&
            lhs.title == rhs.title &&
            lhs.cornerRadius == rhs.cornerRadius
    }
}

extension AdyenTextFieldStyle: Equatable {
    public static func == (lhs: AdyenTextFieldStyle, rhs: AdyenTextFieldStyle) -> Bool {
        lhs.backgroundColor == rhs.backgroundColor &&
            lhs.errorColor == rhs.errorColor &&
            lhs.borderColor == rhs.borderColor &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.cornerRadius == rhs.cornerRadius &&
            lhs.title == rhs.title &&
            lhs.text == rhs.text &&
            lhs.placeholder == rhs.placeholder
    }
}

extension AdyenElements: Equatable {
    public static func == (lhs: AdyenElements, rhs: AdyenElements) -> Bool {
        lhs.buttons == rhs.buttons &&
            lhs.labels == rhs.labels &&
            lhs.switch == rhs.switch &&
            lhs.textField == rhs.textField
    }
}
