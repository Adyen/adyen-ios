//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal class FormAddressLookupItemView: FormSelectableValueItemView<PostalAddress?, FormAddressLookupItem> {
    
    override internal func reset() {
        item.value = PostalAddress()
        resetValidationStatus()
    }
}
