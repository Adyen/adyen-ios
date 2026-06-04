//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit

/// Helper for creating distinctive themes in UI tests.
/// Uses easily verifiable colors that are unlikely to match default values.
internal enum TestTheme {

    // MARK: - Expected Style Structs

    /// Expected text field styling for assertions
    internal struct TextFieldStyle {
        internal let titleColor: UIColor
        internal let titleFont: UIFont
        internal let textColor: UIColor
        internal let textFont: UIFont
        internal let containerColor: UIColor
        internal let cornerRadius: CGFloat
    }

    /// Expected button styling for assertions
    internal struct ButtonStyle {
        internal let backgroundColor: UIColor
        internal let textColor: UIColor
        internal let cornerRadius: CGFloat
    }

    // MARK: - Distinctive Test Values

    /// Default distinctive colors for testing
    internal enum Colors {
        internal static let primary: UIColor = .systemPink
        internal static let container: UIColor = .yellow
        internal static let containerOutline: UIColor = .init(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        internal static let highlight: UIColor = .blue
        internal static let buttonBackground: UIColor = .red
        internal static let buttonText: UIColor = .white
    }

    /// Default corner radius for buttons
    internal static let buttonCornerRadius: CGFloat = 12

    /// Default corner radius for text fields (NOT customizable via theme)
    internal static let textFieldCornerRadius: CGFloat = 14

    // MARK: - Theme Creation

    /// Creates a distinctive theme for UI testing with easily verifiable colors.
    internal static func distinctive() -> CheckoutTheme {
        let colors = CheckoutColors(
            container: Colors.container,
            containerOutline: Colors.containerOutline,
            primary: Colors.primary,
            highlight: Colors.highlight
        )
        return CheckoutTheme(colors: colors)
            .primaryButton(
                backgroundColor: Colors.buttonBackground,
                textColor: Colors.buttonText,
                cornerRadius: buttonCornerRadius
            )
            .cornerRadius(buttonCornerRadius)
    }

    // MARK: - Expected Styles

    /// Returns the expected text field style for the distinctive theme
    internal static var expectedTextFieldStyle: TextFieldStyle {
        TextFieldStyle(
            titleColor: Colors.primary,
            titleFont: UIFont.systemFont(ofSize: 17, weight: .semibold),
            textColor: Colors.primary,
            textFont: UIFont.systemFont(ofSize: 17, weight: .regular),
            containerColor: Colors.container,
            cornerRadius: textFieldCornerRadius
        )
    }

    /// Returns the expected button style for the distinctive theme
    internal static var expectedButtonStyle: ButtonStyle {
        ButtonStyle(
            backgroundColor: Colors.buttonBackground,
            textColor: Colors.buttonText,
            cornerRadius: buttonCornerRadius
        )
    }
}

extension CheckoutTheme {

    private func theme(with elements: AdyenElements) -> CheckoutTheme {
        CheckoutTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }

    private func theme(updatingPrimaryButton primaryButton: AdyenButtonStyle) -> CheckoutTheme {
        var newElements = elements
        newElements.buttons.primary = primaryButton
        return theme(with: newElements)
    }

    private func theme(updatingDestructiveButton destructiveButton: AdyenButtonStyle) -> CheckoutTheme {
        var newElements = elements
        newElements.buttons.destructive = destructiveButton
        return theme(with: newElements)
    }

    private func theme(updatingBodyLabel bodyLabel: AdyenLabelStyle) -> CheckoutTheme {
        var newElements = elements
        newElements.labels.body = bodyLabel
        return theme(with: newElements)
    }

    private func buttonStyle(
        from style: AdyenButtonStyle,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        disabledTextColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) -> AdyenButtonStyle {
        var newStyle = style
        newStyle.backgroundColor = backgroundColor ?? newStyle.backgroundColor
        newStyle.textColor = textColor ?? newStyle.textColor
        newStyle.disabledBackgroundColor = disabledBackgroundColor ?? newStyle.disabledBackgroundColor
        newStyle.disabledTextColor = disabledTextColor ?? newStyle.disabledTextColor

        if let cornerRadius {
            newStyle.cornerRadius = .fixed(cornerRadius)
        }

        return newStyle
    }

    internal func bodyLabel(
        font: UIFont? = nil,
        color: UIColor? = nil,
        disabledColor: UIColor? = nil,
        textAlignment: NSTextAlignment? = nil
    ) -> CheckoutTheme {
        var newBodyLabel = elements.labels.body
        newBodyLabel.font = font ?? newBodyLabel.font
        newBodyLabel.color = color ?? newBodyLabel.color
        newBodyLabel.disabledColor = disabledColor ?? newBodyLabel.disabledColor
        newBodyLabel.textAlignment = textAlignment ?? newBodyLabel.textAlignment

        return theme(updatingBodyLabel: newBodyLabel)
    }

    internal func primaryButton(
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        disabledTextColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) -> CheckoutTheme {
        let newPrimaryButton = buttonStyle(
            from: elements.buttons.primary,
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            cornerRadius: cornerRadius
        )

        return theme(updatingPrimaryButton: newPrimaryButton)
    }

    internal func destructiveButton(
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        disabledTextColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) -> CheckoutTheme {
        let newDestructiveButton = buttonStyle(
            from: elements.buttons.destructive,
            backgroundColor: backgroundColor,
            textColor: textColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            cornerRadius: cornerRadius
        )

        return theme(updatingDestructiveButton: newDestructiveButton)
    }
}
