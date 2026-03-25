//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import UIKit

/// Example themes demonstrating the full range of AdyenTheme configuration options.
/// Each theme showcases different aspects of the theming system.
internal enum ExampleAppTheme: String, CaseIterable {
    case defaultTheme = "Default"
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case midnight = "Midnight"
    case minimal = "Minimal"
    case rounded = "Rounded"
    case corporate = "Corporate"
    case playful = "Playful"
    
    internal static let defaultOption = ExampleAppTheme.defaultTheme
    
    /// Returns the corresponding AdyenTheme for this appearance style.
    internal var theme: AdyenTheme {
        switch self {
        case .defaultTheme:
            return defaultAppTheme
        case .ocean:
            return oceanTheme
        case .forest:
            return forestTheme
        case .sunset:
            return sunsetTheme
        case .midnight:
            return midnightTheme
        case .minimal:
            return minimalTheme
        case .rounded:
            return roundedTheme
        case .corporate:
            return corporateTheme
        case .playful:
            return playfulTheme
        }
    }
    
    // MARK: - Theme Definitions
    
    /// Default theme - SDK defaults with Adyen green accent
    /// Demonstrates: Basic primary button customization
    private var defaultAppTheme: AdyenTheme {
        let adyenGreen = UIColor(red: 0.04, green: 0.75, blue: 0.33, alpha: 1.0) // #0ABF53
        
        return AdyenTheme.default
            .primaryButton(backgroundColor: adyenGreen)
    }
    
    /// Ocean theme - Deep blue color scheme
    /// Demonstrates: Full color palette customization with AdyenColors
    private var oceanTheme: AdyenTheme {
        let deepBlue = UIColor(red: 0.02, green: 0.216, blue: 0.494, alpha: 1.0) // #053779
        let lightBlue = UIColor(red: 0.0, green: 0.631, blue: 0.894, alpha: 1.0) // #00A1E4
        let oceanBackground = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0) // Light blue tint
        let containerColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1.0)
        
        return AdyenTheme(
            colors: AdyenColors(
                background: oceanBackground,
                container: containerColor,
                containerOutline: lightBlue.withAlphaComponent(0.3),
                primary: deepBlue,
                textOnPrimary: .white,
                highlight: lightBlue,
                destructive: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0),
                text: deepBlue,
                textSecondary: deepBlue.withAlphaComponent(0.6)
            )
        )
        .primaryButton(
            backgroundColor: deepBlue,
            textColor: .white,
            disabledBackgroundColor: deepBlue.withAlphaComponent(0.4),
            disabledTextColor: .white.withAlphaComponent(0.6),
            cornerRadius: 8.0
        )
        .destructiveButton(
            backgroundColor: .clear,
            textColor: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0),
            cornerRadius: 8.0
        )
        .bodyLabel(
            color: deepBlue,
            textAlignment: .left
        )
        .cornerRadius(8.0)
    }
    
    /// Forest theme - Natural green tones
    /// Demonstrates: Custom fonts with body label styling
    private var forestTheme: AdyenTheme {
        let forestGreen = UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0) // #228B22
        let darkGreen = UIColor(red: 0.0, green: 0.39, blue: 0.0, alpha: 1.0) // #006400
        let leafGreen = UIColor(red: 0.20, green: 0.80, blue: 0.20, alpha: 1.0) // #33CC33
        
        let bodyFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        let emphasizedFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        
        return AdyenTheme(
            colors: AdyenColors(
                background: UIColor(red: 0.97, green: 0.99, blue: 0.97, alpha: 1.0),
                container: UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0),
                containerOutline: forestGreen.withAlphaComponent(0.3),
                primary: forestGreen,
                textOnPrimary: .white,
                highlight: leafGreen,
                destructive: UIColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0),
                success: leafGreen,
                text: darkGreen,
                textSecondary: forestGreen.withAlphaComponent(0.7)
            )
        )
        .primaryButton(
            backgroundColor: forestGreen,
            textColor: .white,
            disabledBackgroundColor: forestGreen.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.5),
            cornerRadius: 12.0
        )
        .bodyLabel(
            font: bodyFont,
            color: darkGreen,
            disabledColor: darkGreen.withAlphaComponent(0.4),
            textAlignment: .left
        )
        .cornerRadius(12.0)
    }
    
    /// Sunset theme - Warm orange and red tones
    /// Demonstrates: Gradient-like warm color scheme with custom disabled states
    private var sunsetTheme: AdyenTheme {
        let sunsetOrange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0) // #FF7300
        let warmRed = UIColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0) // #E64033
        let goldenYellow = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // #FFD700
        let darkBrown = UIColor(red: 0.36, green: 0.20, blue: 0.09, alpha: 1.0) // #5C3317
        
        return AdyenTheme(
            colors: AdyenColors(
                background: UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1.0),
                container: UIColor(red: 1.0, green: 0.96, blue: 0.90, alpha: 1.0),
                containerOutline: sunsetOrange.withAlphaComponent(0.3),
                primary: sunsetOrange,
                textOnPrimary: .white,
                highlight: goldenYellow,
                destructive: warmRed,
                textOnDestructive: .white,
                disabled: UIColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0),
                textOnDisabled: UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0),
                separator: sunsetOrange.withAlphaComponent(0.2),
                text: darkBrown,
                textSecondary: darkBrown.withAlphaComponent(0.6)
            )
        )
        .primaryButton(
            backgroundColor: sunsetOrange,
            textColor: .white,
            disabledBackgroundColor: sunsetOrange.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.5),
            cornerRadius: 6.0
        )
        .destructiveButton(
            backgroundColor: warmRed,
            textColor: .white,
            disabledBackgroundColor: warmRed.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.5),
            cornerRadius: 6.0
        )
        .bodyLabel(color: darkBrown)
        .cornerRadius(6.0)
    }
    
    /// Midnight theme - Dark mode with accent colors
    /// Demonstrates: Full dark mode color scheme with all color properties
    private var midnightTheme: AdyenTheme {
        let accentPurple = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0) // #9966E6
        let darkBackground = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0) // #14141F
        let containerDark = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1.0) // #1F1F2E
        let lightText = UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1.0) // #EDEDED
        let mutedText = UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0) // #9999A6
        
        return AdyenTheme(
            colors: AdyenColors(
                background: darkBackground,
                container: containerDark,
                containerOutline: UIColor(white: 1.0, alpha: 0.15),
                primary: accentPurple,
                textOnPrimary: .white,
                highlight: accentPurple,
                destructive: UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0),
                success: UIColor(red: 0.3, green: 0.85, blue: 0.5, alpha: 1.0),
                textOnDestructive: .white,
                disabled: UIColor(white: 0.25, alpha: 1.0),
                textOnDisabled: UIColor(white: 0.5, alpha: 1.0),
                separator: UIColor(white: 1.0, alpha: 0.1),
                text: lightText,
                textSecondary: mutedText,
                supportShadow: UIColor.black.withAlphaComponent(0.5)
            )
        )
        .primaryButton(
            backgroundColor: accentPurple,
            textColor: .white,
            disabledBackgroundColor: accentPurple.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.4),
            cornerRadius: 8.0
        )
        .destructiveButton(
            backgroundColor: .clear,
            textColor: UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0),
            cornerRadius: 8.0
        )
        .bodyLabel(
            color: lightText,
            disabledColor: mutedText
        )
        .cornerRadius(8.0)
    }
    
    /// Minimal theme - Clean black and white design
    /// Demonstrates: Sharp corners (0 radius) and monochrome styling
    private var minimalTheme: AdyenTheme {
        let pureBlack = UIColor.black
        let pureWhite = UIColor.white
        let mediumGray = UIColor(white: 0.5, alpha: 1.0)
        let lightGray = UIColor(white: 0.95, alpha: 1.0)
        
        return AdyenTheme(
            colors: AdyenColors(
                background: pureWhite,
                container: lightGray,
                containerOutline: UIColor(white: 0.8, alpha: 1.0),
                primary: pureBlack,
                textOnPrimary: pureWhite,
                highlight: pureBlack,
                destructive: pureBlack,
                textOnDestructive: pureWhite,
                disabled: UIColor(white: 0.9, alpha: 1.0),
                textOnDisabled: mediumGray,
                separator: UIColor(white: 0.85, alpha: 1.0),
                text: pureBlack,
                textSecondary: mediumGray
            )
        )
        .primaryButton(
            backgroundColor: pureBlack,
            textColor: pureWhite,
            disabledBackgroundColor: UIColor(white: 0.7, alpha: 1.0),
            disabledTextColor: pureWhite,
            cornerRadius: 0.0
        )
        .destructiveButton(
            backgroundColor: .clear,
            textColor: pureBlack,
            cornerRadius: 0.0
        )
        .bodyLabel(
            font: UIFont.systemFont(ofSize: 15.0, weight: .light),
            color: pureBlack
        )
        .cornerRadius(0.0)
    }
    
    /// Rounded theme - Soft, pill-shaped buttons
    /// Demonstrates: Large corner radius for pill-shaped elements
    private var roundedTheme: AdyenTheme {
        let softBlue = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // #007AFF (iOS blue)
        let softPink = UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0) // #FF6699
        
        return AdyenTheme(
            colors: AdyenColors(
                background: UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0),
                container: .white,
                containerOutline: softBlue.withAlphaComponent(0.2),
                primary: softBlue,
                textOnPrimary: .white,
                highlight: softBlue,
                destructive: softPink,
                textOnDestructive: .white,
                text: UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0),
                textSecondary: UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
            )
        )
        .primaryButton(
            backgroundColor: softBlue,
            textColor: .white,
            disabledBackgroundColor: softBlue.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.6),
            cornerRadius: 24.0
        )
        .destructiveButton(
            backgroundColor: softPink,
            textColor: .white,
            cornerRadius: 24.0
        )
        .bodyLabel(
            font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
            textAlignment: .center
        )
        .cornerRadius(16.0)
    }
    
    /// Corporate theme - Professional blue-gray scheme
    /// Demonstrates: Subtle, professional color palette with custom text styling
    private var corporateTheme: AdyenTheme {
        let corporateBlue = UIColor(red: 0.15, green: 0.25, blue: 0.45, alpha: 1.0) // #263D73
        let steelGray = UIColor(red: 0.45, green: 0.50, blue: 0.55, alpha: 1.0) // #73808C
        let lightSteelBg = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        
        let professionalFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        
        return AdyenTheme(
            colors: AdyenColors(
                background: lightSteelBg,
                container: .white,
                containerOutline: UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1.0),
                primary: corporateBlue,
                textOnPrimary: .white,
                highlight: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                destructive: UIColor(red: 0.75, green: 0.15, blue: 0.15, alpha: 1.0),
                success: UIColor(red: 0.15, green: 0.55, blue: 0.25, alpha: 1.0),
                textOnDestructive: .white,
                disabled: UIColor(red: 0.88, green: 0.90, blue: 0.92, alpha: 1.0),
                textOnDisabled: steelGray,
                separator: UIColor(red: 0.88, green: 0.90, blue: 0.92, alpha: 1.0),
                text: corporateBlue,
                textSecondary: steelGray
            )
        )
        .primaryButton(
            backgroundColor: corporateBlue,
            textColor: .white,
            disabledBackgroundColor: corporateBlue.withAlphaComponent(0.4),
            disabledTextColor: .white.withAlphaComponent(0.7),
            cornerRadius: 4.0
        )
        .destructiveButton(
            backgroundColor: .clear,
            textColor: UIColor(red: 0.75, green: 0.15, blue: 0.15, alpha: 1.0),
            cornerRadius: 4.0
        )
        .bodyLabel(
            font: professionalFont,
            color: corporateBlue,
            disabledColor: steelGray,
            textAlignment: .left
        )
        .cornerRadius(4.0)
    }
    
    /// Playful theme - Vibrant, fun colors
    /// Demonstrates: Bold, vibrant colors with medium corner radius
    private var playfulTheme: AdyenTheme {
        let vibrantPink = UIColor(red: 1.0, green: 0.2, blue: 0.5, alpha: 1.0) // #FF3380
        let electricBlue = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0) // #00CCFF
        let sunnyYellow = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // #FFE600
        let darkPurple = UIColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1.0) // #4D1A66
        
        let funFont = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        
        return AdyenTheme(
            colors: AdyenColors(
                background: UIColor(red: 1.0, green: 0.98, blue: 0.98, alpha: 1.0),
                container: .white,
                containerOutline: vibrantPink.withAlphaComponent(0.2),
                primary: vibrantPink,
                textOnPrimary: .white,
                highlight: electricBlue,
                destructive: UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0),
                success: UIColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1.0),
                textOnDestructive: .white,
                disabled: UIColor(red: 0.95, green: 0.9, blue: 0.92, alpha: 1.0),
                textOnDisabled: UIColor(red: 0.7, green: 0.6, blue: 0.65, alpha: 1.0),
                separator: vibrantPink.withAlphaComponent(0.15),
                text: darkPurple,
                textSecondary: darkPurple.withAlphaComponent(0.6)
            )
        )
        .primaryButton(
            backgroundColor: vibrantPink,
            textColor: .white,
            disabledBackgroundColor: vibrantPink.withAlphaComponent(0.3),
            disabledTextColor: .white.withAlphaComponent(0.5),
            cornerRadius: 14.0
        )
        .destructiveButton(
            backgroundColor: UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0),
            textColor: .white,
            cornerRadius: 14.0
        )
        .bodyLabel(
            font: funFont,
            color: darkPurple,
            textAlignment: .center
        )
        .cornerRadius(14.0)
    }
}
