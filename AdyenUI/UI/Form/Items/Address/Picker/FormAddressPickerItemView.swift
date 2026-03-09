//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal class FormAddressPickerItemView: FormSelectableValueItemView<PostalAddress, FormAddressPickerItem> {
    
    internal required init(item: FormAddressPickerItem, theme: AdyenTheme) {
        super.init(item: item, theme: theme)
        self.numberOfLines = 1
        valueLabel.apply(theme.elements.textField.text)
    }
    
}
