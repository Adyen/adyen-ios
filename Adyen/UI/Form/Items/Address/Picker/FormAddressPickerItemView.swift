//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal class FormAddressPickerItemView: FormSelectableValueItemView<PostalAddress, FormAddressPickerItem> {
    
    internal required init(item: FormAddressPickerItem) {
        super.init(item: item)
        self.numberOfLines = 0
    }
    
    override internal func reset() {
        item.value = PostalAddress()
        resetValidationStatus()
    }
}
