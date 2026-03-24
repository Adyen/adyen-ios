//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import AdyenUI
import Foundation

/// Builds an `ADYAppearanceConfiguration` from an `AdyenTheme`.
///
/// This struct transforms the Adyen SDK's theming system into the 3DS2 SDK's appearance configuration,
/// mapping colors, fonts, and styles from `AdyenTheme` to the corresponding `ADYAppearanceConfiguration` properties.
internal struct ADYAppearanceConfigurationBuilder {
    
    private let theme: AdyenTheme
    
    internal init(theme: AdyenTheme) {
        self.theme = theme
    }
    
    /// Builds and returns an `ADYAppearanceConfiguration` based on the provided `AdyenTheme`.
    internal func build() -> ADYAppearanceConfiguration {
        let config = ADYAppearanceConfiguration()
        
        configureGlobalColors(config)
        configureLabelAppearance(config.labelAppearance)
        configureTextFieldAppearance(config.textFieldAppearance)
        configureButtonAppearances(config)
        configureSwitchAppearance(config.switchAppearance)
        configureNavigationBarAppearance(config.navigationBarAppearance)
        configureSelectAppearance(config.selectAppearance)
        configureInfoAppearance(config.infoAppearance)
        
        // TODO: config.statusBarStyle - no direct mapping in AdyenTheme (system-level setting)
        // TODO: config.modalPresentationStyle - no direct mapping in AdyenTheme (presentation-level setting)
        
        return config
    }
    
    // MARK: - Global Colors
    
    private func configureGlobalColors(_ config: ADYAppearanceConfiguration) {
        let colors = theme.colors
        
        config.backgroundColor = colors.background
        config.textColor = colors.text
        config.borderColor = colors.containerOutline
        config.tintColor = colors.primary
    }
    
    // MARK: - Label Appearance
    
    private func configureLabelAppearance(_ labelAppearance: ADYLabelAppearance) {
        let labels = theme.elements.labels
        let colors = theme.colors
        
        // ADYAppearance base properties (inherited)
        labelAppearance.font = labels.body.font
        labelAppearance.textColor = labels.body.color
        
        // ADYLabelAppearance specific properties
        labelAppearance.headingFont = labels.title.font
        labelAppearance.headingTextColor = labels.title.color
        labelAppearance.subheadingFont = labels.subtitle.font
        labelAppearance.subheadingTextColor = labels.subtitle.color
        labelAppearance.errorTextColor = colors.destructive
        
        // TODO: labelAppearance.headingLineHeight - no direct mapping in AdyenTheme (line height not exposed)
        // TODO: labelAppearance.lineHeight - no direct mapping in AdyenTheme (line height not exposed)
    }
    
    // MARK: - Text Field Appearance
    
    private func configureTextFieldAppearance(_ textFieldAppearance: ADYTextFieldAppearance) {
        let textField = theme.elements.textField
        
        // ADYAppearance base properties (inherited)
        textFieldAppearance.font = textField.text.font
        textFieldAppearance.textColor = textField.text.color
        
        // ADYTextFieldAppearance specific properties
        textFieldAppearance.borderWidth = textField.borderWidth
        textFieldAppearance.borderColor = textField.borderColor
        textFieldAppearance.cornerRadius = textField.cornerRadius.cgFloatValue
        
        // TODO: textFieldAppearance.keyboardAppearance - no direct mapping in AdyenTheme (keyboard style not exposed)
    }
    
    // MARK: - Button Appearances
    
    private func configureButtonAppearances(_ config: ADYAppearanceConfiguration) {
        let buttons = theme.elements.buttons
        let defaultCornerRadius = theme.attributes.cornerRadius
        
        // Submit, Continue, Next, OOB buttons use primary style
        let primaryButtonTypes: [ADYAppearanceButtonType] = [.submit, .continue, .next, .OOB]
        for buttonType in primaryButtonTypes {
            configureButtonAppearance(
                config.buttonAppearance(for: buttonType),
                with: buttons.primary,
                defaultCornerRadius: defaultCornerRadius
            )
        }
        
        // Cancel button uses destructive style
        configureButtonAppearance(
            config.buttonAppearance(for: .cancel),
            with: buttons.destructive,
            defaultCornerRadius: defaultCornerRadius
        )
        
        // Resend button uses secondary style
        configureButtonAppearance(
            config.buttonAppearance(for: .resend),
            with: buttons.secondary,
            defaultCornerRadius: defaultCornerRadius
        )
    }
    
    private func configureButtonAppearance(
        _ buttonAppearance: ADYButtonAppearance,
        with style: AdyenButtonStyle,
        defaultCornerRadius: CGFloat
    ) {
        // ADYAppearance base properties (inherited)
        // TODO: buttonAppearance.font - no direct mapping in AdyenTheme (AdyenButtonStyle doesn't expose font)
        // TODO: buttonAppearance.textColor is set below as ADYButtonAppearance overrides it
        
        // ADYButtonAppearance specific properties
        buttonAppearance.backgroundColor = style.backgroundColor
        buttonAppearance.textColor = style.textColor
        buttonAppearance.disabledBackgroundColor = style.disabledBackgroundColor
        buttonAppearance.disabledTextColor = style.disabledTextColor
        buttonAppearance.cornerRadius = style.cornerRadius?.cgFloatValue ?? defaultCornerRadius
        
        // TODO: buttonAppearance.highlightedBackgroundColor - no direct mapping in AdyenTheme (highlighted state not exposed)
        // TODO: buttonAppearance.textTransform - no direct mapping in AdyenTheme (text transform not exposed)
    }
    
    // MARK: - Switch Appearance
    
    private func configureSwitchAppearance(_ switchAppearance: ADYSwitchAppearance) {
        let switchStyle = theme.elements.switch
        
        // ADYAppearance base properties (inherited)
        switchAppearance.font = switchStyle.title.font
        switchAppearance.textColor = switchStyle.title.color
        
        // ADYSwitchAppearance specific properties
        if let tintColor = switchStyle.tintColor {
            switchAppearance.switchTintColor = tintColor
        }
    }
    
    // MARK: - Navigation Bar Appearance
    
    private func configureNavigationBarAppearance(_ navigationBarAppearance: ADYNavigationBarAppearance) {
        let labels = theme.elements.labels
        let colors = theme.colors
        
        // ADYAppearance base properties (inherited)
        navigationBarAppearance.font = labels.subtitle.font
        navigationBarAppearance.textColor = colors.text
        
        // ADYNavigationBarAppearance specific properties
        // TODO: navigationBarAppearance.title - no direct mapping in AdyenTheme (app-specific, set by merchant)
        // TODO: navigationBarAppearance.cancelButtonTitle - no direct mapping in AdyenTheme (app-specific, set by merchant)
        // Note: navigationBarAppearance.backgroundColor is deprecated for iOS 26+
    }
    
    // MARK: - Select Appearance
    
    private func configureSelectAppearance(_ selectAppearance: ADYSelectAppearance) {
        let colors = theme.colors
        let labels = theme.elements.labels
        
        // ADYAppearance base properties (inherited)
        selectAppearance.font = labels.body.font
        selectAppearance.textColor = labels.body.color
        
        // ADYSelectAppearance specific properties
        selectAppearance.borderColor = colors.containerOutline
        selectAppearance.selectionIndicatorTintColor = colors.primary
        
        // TODO: selectAppearance.highlightedBackgroundColor - no direct mapping in AdyenTheme (highlighted state not exposed)
    }
    
    // MARK: - Info Appearance
    
    private func configureInfoAppearance(_ infoAppearance: ADYInfoAppearance) {
        let colors = theme.colors
        let labels = theme.elements.labels
        
        // ADYAppearance base properties (inherited)
        infoAppearance.font = labels.body.font
        infoAppearance.textColor = labels.body.color
        
        // ADYInfoAppearance specific properties
        infoAppearance.headingFont = labels.body.font
        infoAppearance.headingTextColor = labels.body.color
        infoAppearance.borderColor = colors.containerOutline
        infoAppearance.selectionIndicatorTintColor = colors.primary
    }
}

// MARK: - CornerRounding Extension

private extension CornerRounding {
    /// Converts the `CornerRounding` enum to a `CGFloat` value suitable for the 3DS2 SDK.
    var cgFloatValue: CGFloat {
        switch self {
        case .none:
            return 0
        case let .fixed(value):
            return value
        case let .percent(value):
            // For percent-based rounding, use a reasonable default since we don't have view dimensions.
            // The 3DS2 SDK expects a fixed CGFloat value.
            // Using a multiplier to approximate a reasonable corner radius.
            return value * 100
        }
    }
}
