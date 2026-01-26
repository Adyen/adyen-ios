//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// A form view representing a plain text input.
@_spi(AdyenInternal)
open class FormTextInputItemView: FormTextItemView<FormTextInputItem> {

    // MARK: - Initializers

    /// Initializes the text item view with theme.
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    public required init(item: FormTextInputItem, theme: AdyenTheme) {
        super.init(item: item, theme: theme)

        observe(item.$isEnabled) { [weak self] isEnabled in
            guard let self else { return }
            self.textField.isEnabled = isEnabled
            if isEnabled {
                self.updateValidationStatus()
                self.textField.textColor = self.theme.elements.textField.text.color
            } else {
                self.resetValidationStatus()
                self.textField.textColor = self.theme.elements.textField.text.disabledColor
            }
        }
        
        observe(item.isHidden) { [weak self] isHidden in
            if isHidden {
                self?.resignFirstResponder()
            }
        }
        
        item.focusHandler = { [weak self] in
            self?.becomeFirstResponder()
        }
    }
}
