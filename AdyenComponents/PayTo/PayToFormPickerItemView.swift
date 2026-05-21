//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormStringPickerItem
    @_spi(AdyenInternal) import class AdyenUI.BaseFormPickerItemView
#endif
import UIKit

internal class PayToIdentifierItem: FormStringPickerItem {
    
    override internal func build(with builder: FormItemViewBuilder) -> any AnyFormItemView {
        PayToFormPickerItemView(item: self, theme: builder.theme)
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
        PayToFormPickerItemView(item: item, theme: theme)
    }
}
