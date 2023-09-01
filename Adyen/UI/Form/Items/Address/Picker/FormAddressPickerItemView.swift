//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

class FormAddressPickerItemView: FormSelectableValueItemView<PostalAddress, FormAddressPickerItem> {
    
    required init(item: FormAddressPickerItem) {
        super.init(item: item)
        self.numberOfLines = 0
    }
    
    override func reset() {
        item.value = PostalAddress()
        resetValidationStatus()
    }
}
