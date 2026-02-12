//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal class PayToIdentifierItem: FormStringPickerItem {
    
    override internal func build(with builder: FormItemViewBuilder) -> any AnyFormItemView {
        PayToFormPickerItemView(item: self)
    }
}

/// Picker subclass view specific to PayTo with its own logic to prevent opening the picker at initial load.
internal class PayToFormPickerItemView: BaseFormPickerItemView<FormStringPickerElement> {
    
    /// To prevent this picker to become first responder initially
    override internal var canBecomeFirstResponder: Bool {
        false
    }
    
}

extension FormItemViewBuilder {
    
    internal func build(with item: PayToIdentifierItem) -> PayToFormPickerItemView {
        PayToFormPickerItemView(item: item)
    }
}
