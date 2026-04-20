//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import UIKit

// MARK: - ExampleColors

internal enum ExampleColors {
    
    // MARK: - Dynamic Colors (adapt to light/dark mode)
    
    /// Purple accent - Light: #9966E6, Dark: #B794F6
    static let purple = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.72, green: 0.58, blue: 0.96, alpha: 1.0)
            : UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
    }
    
    /// Orange accent - Light: #FF7300, Dark: #FF9933
    static let orange = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.60, blue: 0.20, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
    }
    
    /// Gold/yellow - Light: #FFD700, Dark: #FFE44D
    static let gold = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.89, blue: 0.30, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    }
    
    /// Coral red - Light: #E64033, Dark: #FF6B5B
    static let coral = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.42, blue: 0.36, alpha: 1.0)
            : UIColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0)
    }
    
    /// Dark background - Light: #F5F5F7, Dark: #14141F
    static let darkBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
    }
    
    /// Dark container - Light: #FFFFFF, Dark: #1F1F2E
    static let darkContainer = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0)
            : UIColor.white
    }
    
    /// Dynamic white - adapts to dark mode (white in light, near-black in dark)
    static let white = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor.white
    }
    
    // MARK: - System Colors
    
    static let red = UIColor.systemRed
    static let green = UIColor.systemGreen
    static let gray = UIColor.systemGray
    static let gray2 = UIColor.systemGray2
    static let gray6 = UIColor.systemGray6
    static let clear = UIColor.clear
    static let secondaryBackground = UIColor.secondarySystemBackground
    
    // MARK: - Static Colors (do NOT adapt to dark mode)
    
    static let staticWhite = UIColor.white
}

// MARK: - ExampleAppTheme

internal enum ExampleAppTheme: String, CaseIterable {
    case defaultTheme = "Default"
    case midnight = "Midnight"
    case sunset = "Sunset"
    case staticBrand = "Static Brand"
    
    internal static let defaultOption = ExampleAppTheme.defaultTheme
    
    /// Returns the corresponding CheckoutTheme for this appearance style.
    internal var theme: CheckoutTheme {
        switch self {
        case .defaultTheme:
            return defaultAppTheme
        case .midnight:
            return midnightTheme
        case .sunset:
            return sunsetTheme
        case .staticBrand:
            return staticBrandTheme
        }
    }
    
    // MARK: - Theme Definitions
    
    /// Default theme - SDK defaults
    private var defaultAppTheme: CheckoutTheme {
        CheckoutTheme.default
    }
    
    /// Midnight theme - Dark purple accent (Dynamic)
    private var midnightTheme: CheckoutTheme {
        CheckoutTheme(
            colors: AdyenColors(
                background: ExampleColors.darkBackground,
                container: ExampleColors.darkContainer,
                containerOutline: ExampleColors.white.withAlphaComponent(0.15),
                primary: ExampleColors.purple,
                textOnPrimary: ExampleColors.white,
                highlight: ExampleColors.purple,
                destructive: ExampleColors.red,
                success: ExampleColors.green,
                textOnDestructive: ExampleColors.white,
                disabled: ExampleColors.gray,
                textOnDisabled: ExampleColors.gray2,
                separator: ExampleColors.white.withAlphaComponent(0.1),
                text: ExampleColors.purple,
                textSecondary: ExampleColors.gray
            )
        )
        .primaryButton(
            backgroundColor: ExampleColors.purple,
            textColor: ExampleColors.white,
            disabledBackgroundColor: ExampleColors.purple.withAlphaComponent(0.3),
            disabledTextColor: ExampleColors.white.withAlphaComponent(0.4),
            cornerRadius: 8.0
        )
        .destructiveButton(
            backgroundColor: ExampleColors.clear,
            textColor: ExampleColors.red,
            cornerRadius: 8.0
        )
        .cornerRadius(8.0)
    }
    
    /// Sunset theme - Warm orange tones (Dynamic)
    private var sunsetTheme: CheckoutTheme {
        CheckoutTheme(
            colors: AdyenColors(
                background: ExampleColors.gray6,
                container: ExampleColors.secondaryBackground,
                containerOutline: ExampleColors.orange.withAlphaComponent(0.3),
                primary: ExampleColors.orange,
                textOnPrimary: ExampleColors.white,
                highlight: ExampleColors.gold,
                destructive: ExampleColors.coral,
                textOnDestructive: ExampleColors.white,
                disabled: ExampleColors.gray2,
                textOnDisabled: ExampleColors.gray,
                separator: ExampleColors.orange.withAlphaComponent(0.2),
                text: ExampleColors.orange,
                textSecondary: ExampleColors.gray
            )
        )
        .primaryButton(
            backgroundColor: ExampleColors.orange,
            textColor: ExampleColors.white,
            disabledBackgroundColor: ExampleColors.orange.withAlphaComponent(0.3),
            disabledTextColor: ExampleColors.white.withAlphaComponent(0.5),
            cornerRadius: 12.0
        )
        .destructiveButton(
            backgroundColor: ExampleColors.clear,
            textColor: ExampleColors.coral,
            cornerRadius: 12.0
        )
        .cornerRadius(12.0)
    }

    /// Static Brand theme - Non-dynamic colors (does NOT adapt to dark mode)
    private var staticBrandTheme: CheckoutTheme {
        let brandPrimary = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // #007AFF
        let brandAccent = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // #FF9500
        let brandBackground = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0) // #FAFAFC
        let brandContainer = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // #FFFFFF
        let brandText = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0) // #1A1A1F
        let brandTextSecondary = UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0) // #666673
        let brandDestructive = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) // #FF3B30
        
        return CheckoutTheme(
            colors: AdyenColors(
                background: brandBackground,
                container: brandContainer,
                containerOutline: brandPrimary.withAlphaComponent(0.2),
                primary: brandPrimary,
                textOnPrimary: ExampleColors.staticWhite,
                highlight: brandAccent,
                destructive: brandDestructive,
                success: UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0),
                textOnDestructive: ExampleColors.staticWhite,
                disabled: UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0),
                textOnDisabled: UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0),
                separator: UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.0),
                text: brandText,
                textSecondary: brandTextSecondary
            )
        )
        .primaryButton(
            backgroundColor: brandPrimary,
            textColor: ExampleColors.staticWhite,
            disabledBackgroundColor: brandPrimary.withAlphaComponent(0.4),
            disabledTextColor: ExampleColors.staticWhite.withAlphaComponent(0.6),
            cornerRadius: 10.0
        )
        .destructiveButton(
            backgroundColor: ExampleColors.clear,
            textColor: brandDestructive,
            cornerRadius: 10.0
        )
        .cornerRadius(10.0)
    }
}
