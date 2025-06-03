///
/// Copyright (c) 2021 Adyen N.V.
///
/// This file is open source and available under the MIT license. See the LICENSE file for more info.
///

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a form card expiry date item.
internal final class FormCardExpiryDateItemView: FormTextItemView<FormCardExpiryDateItem> {
    
    internal required init(item: FormCardExpiryDateItem) {
        super.init(item: item)

        setupAccessibility()
        observe(item.$placeholder) { [weak self] _ in
            self?.setupAccessibility()
        }
    }

    private func setupAccessibility() {
        let title = item.title ?? ""
        let placeholder = item.placeholder ?? "MM/YY"
        textField.accessibilityLabel = title.isEmpty ? placeholder : "\(title), \(placeholder)"
    }
}
