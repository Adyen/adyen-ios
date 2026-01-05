//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI
import UIKit

/// Helper for creating distinctive themes in UI tests.
/// Uses easily verifiable colors that are unlikely to match default values.
enum TestTheme {

    // MARK: - Expected Style Structs

    /// Expected text field styling for assertions
    struct TextFieldStyle {
        let titleColor: UIColor
        let titleFont: UIFont
        let textColor: UIColor
        let textFont: UIFont
        let containerColor: UIColor
        let cornerRadius: CGFloat
    }

    /// Expected button styling for assertions
    struct ButtonStyle {
        let backgroundColor: UIColor
        let textColor: UIColor
        let cornerRadius: CGFloat
    }

    // MARK: - Distinctive Test Values

    /// Default distinctive colors for testing
    enum Colors {
        static let primary: UIColor = .systemPink
        static let container: UIColor = .systemYellow
        static let containerOutline: UIColor = .init(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        static let highlight: UIColor = .systemBlue
        static let buttonBackground: UIColor = .systemRed
        static let buttonText: UIColor = .white
    }

    /// Default corner radius for buttons
    static let buttonCornerRadius: CGFloat = 12

    /// Default corner radius for text fields (NOT customizable via theme)
    static let textFieldCornerRadius: CGFloat = 14

    // MARK: - Theme Creation

    /// Creates a distinctive theme for UI testing with easily verifiable colors.
    static func distinctive() -> AdyenTheme {
        let colors = AdyenColors(
            container: Colors.container,
            containerOutline: Colors.containerOutline,
            primary: Colors.primary,
            highlight: Colors.highlight
        )
        return AdyenTheme(colors: colors)
            .primaryButton(
                backgroundColor: Colors.buttonBackground,
                textColor: Colors.buttonText,
                cornerRadius: buttonCornerRadius
            )
            .cornerRadius(buttonCornerRadius)
    }

    // MARK: - Expected Styles

    /// Returns the expected text field style for the distinctive theme
    static var expectedTextFieldStyle: TextFieldStyle {
        TextFieldStyle(
            titleColor: Colors.primary,
            titleFont: UIFont.systemFont(ofSize: 17, weight: .semibold), // bodyEmphasized
            textColor: Colors.primary,
            textFont: UIFont.systemFont(ofSize: 17, weight: .regular), // body
            containerColor: Colors.container,
            cornerRadius: textFieldCornerRadius
        )
    }

    /// Returns the expected button style for the distinctive theme
    static var expectedButtonStyle: ButtonStyle {
        ButtonStyle(
            backgroundColor: Colors.buttonBackground,
            textColor: Colors.buttonText,
            cornerRadius: buttonCornerRadius
        )
    }
}
