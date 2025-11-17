//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class FormPhoneNumberItemView: FormTextItemView<FormPhoneNumberItem> {
    
    /// Initializes the phone number item view with theme.
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    override internal init(item: FormPhoneNumberItem, theme: AdyenTheme) {
        super.init(item: item, theme: theme)
        applyTextFieldLeftAccessoryView(textField: textField)
        textField.textContentType = .telephoneNumber
    }

    override internal var childItemViews: [AnyFormItemView] {
        [phoneExtensionView]
    }
    
    // MARK: - Private
    
    private lazy var phoneExtensionView: AnyFormItemView = {
        let view = item.phonePrefixItem.build(with: FormItemViewBuilder())
        view.accessibilityIdentifier = item.phonePrefixItem.identifier
        view.preservesSuperviewLayoutMargins = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func applyTextFieldLeftAccessoryView(textField: UITextField) {
        if UIView.userInterfaceLayoutDirection(for: textField.semanticContentAttribute) == .rightToLeft {
            // If the interface direction is right to left we set the `rightView` so it shows up on the left side
            // as in RTL languages the phone number still gets read from left to right
            textField.rightViewMode = .always
            textField.rightView = phoneExtensionView
        } else {
            textField.leftViewMode = .always
            textField.leftView = phoneExtensionView
        }
    }
}
