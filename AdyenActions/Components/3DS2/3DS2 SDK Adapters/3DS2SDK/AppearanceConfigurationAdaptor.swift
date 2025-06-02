//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift

extension Adyen3DS2.ADYAppearanceConfiguration {
    @MainActor
    var appearanceConfiguration: Adyen3DS2_Swift.AppearanceConfiguration {
        Adyen3DS2_Swift.AppearanceConfiguration(
            statusBarStyle: statusBarStyle,
            backgroundColor: backgroundColor,
            textColor: textColor,
            borderColor: borderColor,
            tintColor: tintColor,
            navigationBarAppearance: navigationBarAppearance.navigationBarAppearance,
            labelAppearance: labelAppearance.appearance,
            textFieldAppearance: textFieldAppearance.appearance,
            selectAppearance: selectAppearance.appearance,
            switchAppearance: switchAppearance.appearance,
            infoAppearance: infoAppearance.appearance,
            modalPresentationStyle: modalPresentationStyle
        )
    }
}

extension Adyen3DS2.ADYNavigationBarAppearance {
    var navigationBarAppearance: Adyen3DS2_Swift.NavigationBarAppearance {
        Adyen3DS2_Swift.NavigationBarAppearance(
            font: font,
            textColor: textColor,
            title: title,
            cancelButtonTitle: cancelButtonTitle,
            backgroundColor: backgroundColor
        )
    }
}

extension Adyen3DS2.ADYLabelAppearance {
    var appearance: Adyen3DS2_Swift.LabelAppearance {
        Adyen3DS2_Swift.LabelAppearance(
            font: font,
            textColor: textColor,
            headingFont: headingFont,
            headingTextColor: headingTextColor,
            headingLineHeight: headingLineHeight,
            subheadingFont: subheadingFont,
            subheadingTextColor: subheadingTextColor,
            errorTextColor: errorTextColor,
            lineHeight: lineHeight
        )
    }
}

extension Adyen3DS2.ADYTextFieldAppearance {
    var appearance: Adyen3DS2_Swift.TextFieldAppearance {
        Adyen3DS2_Swift.TextFieldAppearance(
            font: font,
            textColor: textColor,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            keyboardAppearance: keyboardAppearance
        )
    }
}

extension Adyen3DS2.ADYSelectAppearance {
    @MainActor
    var appearance: Adyen3DS2_Swift.SelectAppearance {
        Adyen3DS2_Swift.SelectAppearance(
            font: font,
            textColor: textColor,
            borderColor: borderColor,
            highlightedBackgroundColor: highlightedBackgroundColor,
            selectionIndicatorTintColor: selectionIndicatorTintColor
        )
    }
}

extension Adyen3DS2.ADYSwitchAppearance {
    var appearance: Adyen3DS2_Swift.SwitchAppearance {
        Adyen3DS2_Swift.SwitchAppearance(
            font: font,
            textColor: textColor,
            switchTintColor: switchTintColor
        )
    }
}

extension Adyen3DS2.ADYInfoAppearance {
    var appearance: Adyen3DS2_Swift.InfoAppearance {
        Adyen3DS2_Swift.InfoAppearance(
            font: font,
            textColor: textColor,
            headingFont: headingFont,
            headingTextColor: headingTextColor,
            selectionIndicatorTintColor: selectionIndicatorTintColor,
            borderColor: borderColor
        )
    }
}
