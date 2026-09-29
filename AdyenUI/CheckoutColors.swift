//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal enum DefaultColorsLight {
    internal static let background = UIColor.color(hex: 0xFFFFFF)
    internal static let container = UIColor.color(hex: 0xF4F5F6)
    internal static let containerOutline = UIColor.color(hex: 0x8C959D)
    internal static let primary = UIColor.color(hex: 0x001222)
    internal static let textOnPrimary = UIColor.color(hex: 0xFFFFFF)
    internal static let highlight = UIColor.color(hex: 0x0070F5)
    internal static let destructive = UIColor.color(hex: 0xE22D2D)
    internal static let textOnDestructive = UIColor.color(hex: 0xFFFFFF)
    internal static let disabled = UIColor.color(hex: 0xECEDEF)
    internal static let textOnDisabled = UIColor.color(hex: 0x8D95A3)
    internal static let separator = UIColor.color(hex: 0xDADDDF)
    internal static let text = UIColor.color(hex: 0x00112C)
    internal static let textSecondary = UIColor.color(hex: 0x5C687C)

    internal static let success = UIColor.color(hex: 0x07893C)
    internal static let supportShadow = UIColor.color(hex: 0x001222)
}

internal enum DefaultColorsDark {
    internal static let background = UIColor.color(hex: 0x111111)
    internal static let container = UIColor.color(hex: 0x2A2A2A)
    internal static let containerOutline = UIColor.color(hex: 0x949494)
    internal static let primary = UIColor.color(hex: 0xEDEDED)
    internal static let textOnPrimary = UIColor.color(hex: 0x111111)
    internal static let highlight = UIColor.color(hex: 0x7DB9FF)
    internal static let destructive = UIColor.color(hex: 0xF99C9C)
    internal static let textOnDestructive = UIColor.color(hex: 0x121212)
    internal static let disabled = UIColor.color(hex: 0x363636)
    internal static let textOnDisabled = UIColor.color(hex: 0x7E7E7E)
    internal static let separator = UIColor.color(hex: 0x444444)
    internal static let text = UIColor.color(hex: 0xEDEDED)
    internal static let textSecondary = UIColor.color(hex: 0xA5A5A5)

    internal static let success = UIColor.color(hex: 0x41CD7A)
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
    package var supportShadow: UIColor

    // MARK: - Initializers

    public static let `default` = CheckoutColors()

    private init() {
        self.background = .dynamic(light: DefaultColorsLight.background, dark: DefaultColorsDark.background)
        self.container = .dynamic(light: DefaultColorsLight.container, dark: DefaultColorsDark.container)
        self.containerOutline = .dynamic(light: DefaultColorsLight.containerOutline, dark: DefaultColorsDark.containerOutline)
        self.primary = .dynamic(light: DefaultColorsLight.primary, dark: DefaultColorsDark.primary)
        self.textOnPrimary = .dynamic(light: DefaultColorsLight.textOnPrimary, dark: DefaultColorsDark.textOnPrimary)
        self.highlight = .dynamic(light: DefaultColorsLight.highlight, dark: DefaultColorsDark.highlight)
        self.destructive = .dynamic(light: DefaultColorsLight.destructive, dark: DefaultColorsDark.destructive)
        self.textOnDestructive = .dynamic(light: DefaultColorsLight.textOnDestructive, dark: DefaultColorsDark.textOnDestructive)
        self.disabled = .dynamic(light: DefaultColorsLight.disabled, dark: DefaultColorsDark.disabled)
        self.textOnDisabled = .dynamic(light: DefaultColorsLight.textOnDisabled, dark: DefaultColorsDark.textOnDisabled)
        self.separator = .dynamic(light: DefaultColorsLight.separator, dark: DefaultColorsDark.separator)
        self.text = .dynamic(light: DefaultColorsLight.text, dark: DefaultColorsDark.text)
        self.textSecondary = .dynamic(light: DefaultColorsLight.textSecondary, dark: DefaultColorsDark.textSecondary)

        self.success = .dynamic(light: DefaultColorsLight.success, dark: DefaultColorsDark.success)
        self.supportShadow = .dynamic(light: DefaultColorsLight.supportShadow, dark: DefaultColorsDark.supportShadow)
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
        self.supportShadow = defaultScheme.supportShadow
    }
}

extension UIColor {

    fileprivate static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}
