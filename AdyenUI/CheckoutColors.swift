//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal enum DefaultColorsLight {
    internal static let backgroundPrimary = UIColor.color(hex: 0xFFFFFF)
    internal static let backgroundSecondary = UIColor.color(hex: 0xF7F7F8)
    internal static let backgroundQuaternary = UIColor.color(hex: 0x525252)
    internal static let backgroundDisabled = UIColor.color(hex: 0xEEEFF1)
    internal static let critical = UIColor.color(hex: 0xE22D2D)
    internal static let warning = UIColor.color(hex: 0xAB6600)
    internal static let success = UIColor.color(hex: 0x07893C)
    internal static let highlight = UIColor.color(hex: 0x0070F5)
    internal static let labelPrimary = UIColor.color(hex: 0x00112C)
    internal static let labelSecondary = UIColor.color(hex: 0x5C687C)
    internal static let labelDisabled = UIColor.color(hex: 0x8D95A3)
    internal static let separatorPrimary = UIColor.color(hex: 0xDADDDF)
    internal static let supportShadow = UIColor.color(hex: 0x001222)
}

internal enum DefaultColorsDark {
    internal static let backgroundPrimary = UIColor.color(hex: 0x121212)
    internal static let backgroundSecondary = UIColor.color(hex: 0x1C1C1E)
    internal static let backgroundQuaternary = UIColor.color(hex: 0xC0C5CA)
    internal static let backgroundDisabled = UIColor.color(hex: 0xEEEFF1)
    internal static let critical = UIColor.color(hex: 0xF99C9C)
    internal static let warning = UIColor.color(hex: 0xFF9E11)
    internal static let success = UIColor.color(hex: 0x41CD7A)
    internal static let highlight = UIColor.color(hex: 0x7DB9FF)
    internal static let labelPrimary = UIColor.color(hex: 0xFFFFFF)
    internal static let labelSecondary = UIColor.color(hex: 0xA5A5A5)
    internal static let labelDisabled = UIColor.color(hex: 0x7E7E7E)
    internal static let separatorPrimary = UIColor.color(hex: 0x444444)
    internal static let supportShadow = UIColor.color(hex: 0x070707)
}

public struct CheckoutColors: Equatable {

    public var background: UIColor
    public var container: UIColor
    public var containerOutline: UIColor
    public var primary: UIColor
    public var textOnPrimary: UIColor
    public var highlight: UIColor
    public var destructive: UIColor
    public var textOnDestructive: UIColor
    public var disabled: UIColor
    public var textOnDisabled: UIColor
    public var separator: UIColor
    public var text: UIColor
    public var textSecondary: UIColor

    package var success: UIColor
    package var warning: UIColor
    package var supportShadow: UIColor

    // MARK: - Initializers

    public static let `default` = CheckoutColors()

    private init() {
        self.background = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundPrimary : DefaultColorsLight.backgroundPrimary
        }

        self.container = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundSecondary : DefaultColorsLight.backgroundSecondary
        }

        self.containerOutline = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundSecondary : DefaultColorsLight.backgroundSecondary
        }

        self.primary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.labelPrimary : DefaultColorsLight.labelPrimary
        }

        self.textOnPrimary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundPrimary : DefaultColorsLight.backgroundPrimary
        }

        self.highlight = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.highlight : DefaultColorsLight.highlight
        }

        self.destructive = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.critical : DefaultColorsLight.critical
        }

        self.success = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.success : DefaultColorsLight.success
        }

        self.warning = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.warning : DefaultColorsLight.warning
        }

        self.textOnDestructive = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundPrimary : DefaultColorsLight.backgroundPrimary
        }

        self.disabled = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.backgroundDisabled : DefaultColorsLight.backgroundDisabled
        }

        self.textOnDisabled = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.labelDisabled : DefaultColorsLight.labelDisabled
        }

        self.separator = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.separatorPrimary : DefaultColorsLight.separatorPrimary
        }

        self.text = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.labelPrimary : DefaultColorsLight.labelPrimary
        }

        self.textSecondary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.labelSecondary : DefaultColorsLight.labelSecondary
        }

        self.supportShadow = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? DefaultColorsDark.supportShadow : DefaultColorsLight.supportShadow
        }
    }

    public init(
        background: UIColor? = nil,
        container: UIColor? = nil,
        containerOutline: UIColor? = nil,
        primary: UIColor? = nil,
        textOnPrimary: UIColor? = nil,
        highlight: UIColor? = nil,
        destructive: UIColor? = nil,
        textOnDestructive: UIColor? = nil,
        disabled: UIColor? = nil,
        textOnDisabled: UIColor? = nil,
        separator: UIColor? = nil,
        text: UIColor? = nil,
        textSecondary: UIColor? = nil
    ) {
        let defaultScheme = CheckoutColors.default

        self.background = background ?? defaultScheme.background
        self.container = container ?? defaultScheme.container
        self.containerOutline = containerOutline ?? defaultScheme.containerOutline
        self.primary = primary ?? defaultScheme.primary
        self.textOnPrimary = textOnPrimary ?? defaultScheme.textOnPrimary
        self.highlight = highlight ?? defaultScheme.highlight
        self.destructive = destructive ?? defaultScheme.destructive
        self.textOnDestructive = textOnDestructive ?? defaultScheme.textOnDestructive
        self.disabled = disabled ?? defaultScheme.disabled
        self.textOnDisabled = textOnDisabled ?? defaultScheme.textOnDisabled
        self.separator = separator ?? defaultScheme.separator
        self.text = text ?? defaultScheme.text
        self.textSecondary = textSecondary ?? defaultScheme.textSecondary
        self.success = defaultScheme.success
        self.warning = defaultScheme.warning
        self.supportShadow = defaultScheme.supportShadow
    }
}
