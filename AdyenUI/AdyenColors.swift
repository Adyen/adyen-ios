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
    internal static let success = UIColor.color(hex: 0x41CD7A)
    internal static let highlight = UIColor.color(hex: 0x7DB9FF)
    internal static let labelPrimary = UIColor.color(hex: 0xFFFFFF)
    internal static let labelSecondary = UIColor.color(hex: 0xA5A5A5)
    internal static let labelDisabled = UIColor.color(hex: 0x7E7E7E)
    internal static let separatorPrimary = UIColor.color(hex: 0x444444)
    internal static let supportShadow = UIColor.color(hex: 0x070707)
}

// TODO: Robert: Theming: Rename this to CheckoutColors??

/// A color palette for customizing the appearance of Adyen checkout UI components.
///
/// Use `AdyenColors` to match the checkout experience with your app's brand identity.
/// All colors support both light and dark mode when using dynamic `UIColor` values.
///
/// ## Usage
/// ```swift
/// let colors = AdyenColors(
///     background: .systemBackground,
///     primary: .systemBlue,
///     text: .label
/// )
/// let theme = AdyenTheme(colors: colors)
/// ```
///
/// ## Color Categories
/// - **Backgrounds**: `background`, `container`, `disabled`
/// - **Text**: `text`, `textSecondary`, `textOnPrimary`, `textOnDestructive`, `textOnDisabled`
/// - **Interactive**: `primary`, `highlight`, `destructive`, `success`
/// - **Structural**: `containerOutline`, `separator`
///
/// - Note: Ensure sufficient contrast ratios (WCAG AA 4.5:1 minimum) between text and background colors.
public struct AdyenColors: Equatable {

    package var background: UIColor
    package var container: UIColor
    package var containerOutline: UIColor
    package var primary: UIColor
    package var textOnPrimary: UIColor
    package var highlight: UIColor
    package var destructive: UIColor
    package var success: UIColor
    package var textOnDestructive: UIColor
    package var disabled: UIColor
    package var textOnDisabled: UIColor
    package var separator: UIColor
    package var text: UIColor
    package var textSecondary: UIColor

    // TODO: Robert: Theming: support shadow needs to be discussed with Arjen if we can use any existing colors. This should not be public anyway.
    package var supportShadow: UIColor

    // MARK: - Initializers

    public static var `default`: AdyenColors = .init()

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

    /// Creates a custom color palette for Adyen checkout components.
    ///
    /// Pass `nil` for any parameter to use the default color (supports light/dark mode automatically).
    ///
    /// - Parameters:
    ///
    ///   - background: **Screen background** — The root background color for all checkout screens.
    ///     - *Used in:* `SecuredViewController`, `FormViewController`, `ListViewController`, text field backgrounds
    ///     - *Examples:* Drop-in payment method list background, card entry form background, stored card input screen
    ///
    ///   - container: **Grouped content background** — Background for elements containing related content.
    ///     - *Used in:* Text input field containers, toggle/switch backgrounds, secondary buttons, error message containers
    ///     - *Examples:* Card number input field container, "Save for my next payment" toggle background, card logo image background
    ///
    ///   - containerOutline: **Input borders (unfocused)** — Border color for input fields in their default state.
    ///     - *Used in:* `AdyenTextFieldStyle.borderColor`
    ///     - *Examples:* Card number field border (unfocused), expiry date field border (unfocused), CVC field border (unfocused)
    ///
    ///   - primary: **Primary action & focused states** — Your brand color for main call-to-action elements and active states.
    ///     - *Used in:* Primary button backgrounds, focused input field borders, toggle tint color, title/body label colors, chevron icons
    ///     - *Examples:* "Pay €50.00" button background, card number field border (when focused), "Save for my next payment" toggle tint
    ///
    ///   - textOnPrimary: **Text on primary buttons** — Text/icon color on `primary`-colored backgrounds.
    ///     - *Used in:* Primary button text and icons
    ///     - *Examples:* "Pay €50.00" button text, "Continue" button text, lock icon on submit button
    ///
    ///   - highlight: **Links & tertiary actions** — Accent color for text-only interactive elements.
    ///     - *Used in:* Tertiary button text color (text-only buttons without background)
    ///     - *Examples:* "Change payment method" link, "Enter code manually" link, "What is this?" help link
    ///
    ///   - destructive: **Error & danger** — Color for destructive actions and error states.
    ///     - *Used in:* Destructive button backgrounds, validation error messages, text field error color
    ///     - *Examples:* "Invalid card number" error message, "Remove stored card" button background, "Required field" validation error
    ///
    ///   - success: **Success & validation** — Color for successful completion and positive validation.
    ///     - *Used in:* Reserved for success states (not currently used in SDK components)
    ///     - *Examples:* Payment success indicators, valid input checkmarks (future use)
    ///
    ///   - textOnDestructive: **Text on destructive buttons** — Text/icon color on `destructive`-colored backgrounds.
    ///     - *Used in:* Destructive button text and icons
    ///     - *Examples:* "Remove" button text, "Delete stored card" button text
    ///
    ///   - disabled: **Disabled background** — Background color for inactive/disabled elements.
    ///     - *Used in:* All button types when disabled (primary, secondary, tertiary, destructive)
    ///     - *Examples:* "Pay €50.00" button when card details are incomplete, "Continue" button before form validation passes
    ///
    ///   - textOnDisabled: **Disabled text** — Muted text color for disabled elements.
    ///     - *Used in:* All button types' text when disabled
    ///     - *Examples:* "Pay €50.00" text when button is disabled, "Continue" text on inactive button
    ///
    ///   - separator: **Divider lines & subtle borders** — Color for visual separators and subtle borders.
    ///     - *Used in:* `FormSeparatorItemView`, payment method list item separators, selectable item borders, logo image borders
    ///     - *Examples:* Line between "Credit Card" and "iDEAL" options, border around payment method logos
    ///
    ///   - text: **Primary text** — Main text color for labels, headings, and body content.
    ///     - *Used in:* Subheadline labels, emphasized footnotes, secondary button text
    ///     - *Examples:* "Card Number" label, "Expiry Date" label, "Credit Card" payment method name, secondary button text
    ///
    ///   - textSecondary: **Secondary text** — Muted text for less prominent content.
    ///     - *Used in:* Input field placeholders, footnote labels, section header subtitles, helper/validation text
    ///     - *Examples:* "1234 5678 9012 3456" placeholder, "MM/YY" placeholder, section subtitle text, "Optional" field hint
    public init(
        background: UIColor? = nil,
        container: UIColor? = nil,
        containerOutline: UIColor? = nil,
        primary: UIColor? = nil,
        textOnPrimary: UIColor? = nil,
        highlight: UIColor? = nil,
        destructive: UIColor? = nil,
        // TODO: Robert: Theming: Success is not available in Android.
        success: UIColor? = nil,
        textOnDestructive: UIColor? = nil,
        disabled: UIColor? = nil,
        textOnDisabled: UIColor? = nil,
        separator: UIColor? = nil,
        text: UIColor? = nil,
        textSecondary: UIColor? = nil
    ) {
        let defaultScheme = AdyenColors.default

        self.background = background ?? defaultScheme.background
        self.container = container ?? defaultScheme.container
        self.containerOutline = containerOutline ?? defaultScheme.containerOutline
        self.primary = primary ?? defaultScheme.primary
        self.textOnPrimary = textOnPrimary ?? defaultScheme.textOnPrimary
        self.success = success ?? defaultScheme.success
        self.highlight = highlight ?? defaultScheme.highlight
        self.destructive = destructive ?? defaultScheme.destructive
        self.textOnDestructive = textOnDestructive ?? defaultScheme.textOnDestructive
        self.disabled = disabled ?? defaultScheme.disabled
        self.textOnDisabled = textOnDisabled ?? defaultScheme.textOnDisabled
        self.separator = separator ?? defaultScheme.separator
        self.text = text ?? defaultScheme.text
        self.textSecondary = textSecondary ?? defaultScheme.textSecondary

        self.supportShadow = defaultScheme.supportShadow
    }
}
