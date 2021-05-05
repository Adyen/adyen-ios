//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal final class FormPhoneNumberItemView: FormTextItemView<FormPhoneNumberItem> {
    
    /// Initializes the split text item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormPhoneNumberItem) {
        super.init(item: item)
        showsSeparator = true
        applyTextFieldLeftAccessoryView(textField: textField)
        textField.textContentType = .telephoneNumber
    }
    
    /// :nodoc:
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
        textField.leftViewMode = .always
        textField.leftView = phoneExtensionView
    }
}
