//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation

/// Builds an `Adyen3DS2.ADYAppearanceConfiguration` from an `AdyenTheme`.
internal struct ADYAppearanceConfigurationBuilder {
    
    private let theme: AdyenTheme
    
    internal init(theme: AdyenTheme) {
        self.theme = theme
    }
    
    internal func build() -> ADYAppearanceConfiguration {
        let config = ADYAppearanceConfiguration()
        configureGlobalColors(config)
        configureLabelAppearance(config.labelAppearance)
        configureTextFieldAppearance(config.textFieldAppearance)
        configureButtonAppearances(config)
        configureSwitchAppearance(config.switchAppearance)
        configureSelectAppearance(config.selectAppearance)
        configureInfoAppearance(config.infoAppearance)
        return config
    }
    
    // MARK: - Global Colors
    
    private func configureGlobalColors(_ config: ADYAppearanceConfiguration) {
        let colors = theme.colors
        config.backgroundColor = colors.background
    }
    
    // MARK: - Label Appearance
    
    private func configureLabelAppearance(_ labelAppearance: ADYLabelAppearance) {
        let labels = theme.elements.labels
        labelAppearance.textColor = labels.body.color
        labelAppearance.headingTextColor = labels.title.color
        labelAppearance.subheadingTextColor = labels.subtitle.color
    }
    
    // MARK: - Text Field Appearance
    
    private func configureTextFieldAppearance(_ textFieldAppearance: ADYTextFieldAppearance) {
        let textField = theme.elements.textField
        textFieldAppearance.textColor = textField.text.color
        textFieldAppearance.borderWidth = textField.borderWidth
        textFieldAppearance.borderColor = textField.borderColor
        textFieldAppearance.cornerRadius = textField.cornerRadius.cgFloatValue
    }
    
    // MARK: - Button Appearances
    
    private func configureButtonAppearances(_ config: ADYAppearanceConfiguration) {
        let buttons = theme.elements.buttons
        let defaultCornerRadius = theme.attributes.cornerRadius

        let primaryButtonTypes: [ADYAppearanceButtonType] = [.submit, .continue, .next]
        for buttonType in primaryButtonTypes {
            configureButtonAppearance(
                config.buttonAppearance(for: buttonType),
                with: buttons.primary,
                defaultCornerRadius: defaultCornerRadius
            )
        }

        let secondaryButtonTypes: [ADYAppearanceButtonType] = [.OOB, .resend]
        for buttonType in secondaryButtonTypes {
            configureButtonAppearance(
                config.buttonAppearance(for: buttonType),
                with: buttons.secondary,
                defaultCornerRadius: defaultCornerRadius
            )
        }

        let cancelButtonAppearance = config.buttonAppearance(for: .cancel)
        cancelButtonAppearance.textColor = theme.colors.primary
    }
    
    private func configureButtonAppearance(
        _ buttonAppearance: ADYButtonAppearance,
        with style: AdyenButtonStyle,
        defaultCornerRadius: CGFloat
    ) {
        buttonAppearance.backgroundColor = style.backgroundColor
        buttonAppearance.textColor = style.textColor
        buttonAppearance.disabledBackgroundColor = style.disabledBackgroundColor
        buttonAppearance.disabledTextColor = style.disabledTextColor
        buttonAppearance.cornerRadius = style.cornerRadius?.cgFloatValue ?? defaultCornerRadius
    }
    
    // MARK: - Switch Appearance
    
    private func configureSwitchAppearance(_ switchAppearance: ADYSwitchAppearance) {
        let switchStyle = theme.elements.switch
        switchAppearance.font = switchStyle.title.font
        switchAppearance.textColor = switchStyle.title.color
        if let tintColor = switchStyle.tintColor {
            switchAppearance.switchTintColor = tintColor
        }
    }
        
    // MARK: - Select Appearance
    
    private func configureSelectAppearance(_ selectAppearance: ADYSelectAppearance) {
        let colors = theme.colors
        let labels = theme.elements.labels
        selectAppearance.textColor = labels.body.color
        selectAppearance.borderColor = colors.separator
        selectAppearance.selectionIndicatorTintColor = colors.primary
    }
    
    // MARK: - Info Appearance
    
    private func configureInfoAppearance(_ infoAppearance: ADYInfoAppearance) {
        let colors = theme.colors
        let labels = theme.elements.labels

        infoAppearance.textColor = labels.body.color
        infoAppearance.headingTextColor = theme.colors.textSecondary
        infoAppearance.borderColor = colors.separator
        infoAppearance.selectionIndicatorTintColor = colors.primary
    }
}

// MARK: - CornerRounding Extension

private extension CornerRounding {
    var cgFloatValue: CGFloat {
        switch self {
        case .none:
            return 0
        case let .fixed(value):
            return value
        case let .percent(value):
            // Using a multiplier to approximate a reasonable corner radius.
            // TODO: Robert: What is a percent CornerRounding? How does it translate to something that is static.
            return value * 100
        }
    }
}
