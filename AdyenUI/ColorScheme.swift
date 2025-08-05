//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct ColorScheme: Equatable {

    public var background: UIColor
    public var container: UIColor
    public var primary: UIColor
    public var textOnPrimary: UIColor
    public var action: UIColor
    public var destructive: UIColor
    public var textOnDestructive: UIColor
    public var disabled: UIColor
    public var textOnDisabled: UIColor
    public var outline: UIColor
    public var text: UIColor
    public var textSecondary: UIColor

    // MARK: - Initializers

    // A static default ColorScheme
    public static var `default`: ColorScheme {
        ColorScheme()
    }

    private init() {
        self.background = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x121212) : .color(hex: 0xFFFFFF)
        }

        self.container = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x1C1C1E) : .color(hex: 0xF7F7F8)
        }

        self.primary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0xEFEFEF) : .color(hex: 0x00112C)
        }

        self.textOnPrimary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x121212) : .color(hex: 0xFFFFFF)
        }

        self.action = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x7DB9FF) : .color(hex: 0x0070F5)
        }

        self.destructive = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0xF99C9C) : .color(hex: 0xE22D2D)
        }

        self.textOnDestructive = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x121212) : .color(hex: 0xFFFFFF)
        }

        self.disabled = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x373737) : .color(hex: 0xEEEFF1)
        }

        self.outline = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0x454545) : .color(hex: 0xDBDEE2)
        }

        self.textOnDisabled = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0xEFEFEF) : .color(hex: 0x00112C)
        }

        self.text = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0xEFEFEF) : .color(hex: 0x00112C)
        }

        self.textSecondary = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .color(hex: 0xEFEFEF) : .color(hex: 0x5C687C)
        }
    }

    public init(
        background: UIColor? = nil,
        container: UIColor? = nil,
        primary: UIColor? = nil,
        textOnPrimary: UIColor? = nil,
        action: UIColor? = nil,
        destructive: UIColor? = nil,
        textOnDestructive: UIColor? = nil,
        disabled: UIColor? = nil,
        textOnDisabled: UIColor? = nil,
        outline: UIColor? = nil,
        text: UIColor? = nil,
        textSecondary: UIColor? = nil
    ) {
        let defaultScheme = ColorScheme.default

        self.background = background ?? defaultScheme.background
        self.container = container ?? defaultScheme.container
        self.primary = primary ?? defaultScheme.primary
        self.textOnPrimary = textOnPrimary ?? defaultScheme.textOnPrimary
        self.action = action ?? defaultScheme.action
        self.destructive = destructive ?? defaultScheme.destructive
        self.textOnDestructive = textOnDestructive ?? defaultScheme.textOnDestructive
        self.disabled = disabled ?? defaultScheme.disabled
        self.textOnDisabled = textOnDisabled ?? defaultScheme.textOnDisabled
        self.outline = outline ?? defaultScheme.outline
        self.text = text ?? defaultScheme.text
        self.textSecondary = textSecondary ?? defaultScheme.textSecondary
    }
}
