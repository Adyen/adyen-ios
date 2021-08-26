//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class FormPhoneExtensionPickerItemView: BaseFormPickerItemView<PhoneExtension> {

    private lazy var phoneExtensionInputControl = PhoneExtensionInputControl(inputView: pickerView,
                                                                             inputAccessoryView: pickerViewToolbar,
                                                                             style: item.style.text)

    override internal func createInputControl() -> PickerTextInputControl {
        phoneExtensionInputControl
    }

    override internal func updateSelection() {
        phoneExtensionInputControl.label = item.value.element.value
        phoneExtensionInputControl.flagView.text = item.value.identifier.adyen.countryFlag
    }

    override internal func initialize() {
        super.initialize()
        showsSeparator = false
    }
}
