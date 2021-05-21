//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class FormPhoneExtensionPickerItemView: BaseFormPickerItemView<PhoneExtensionViewModel> {

    private lazy var phoneExtensionInputControl = PhoneExtensionInputControl(inputView: self.pickerView,
                                                                             style: self.item.style.text)

    override internal func getInputControl() -> PickerTextInputControl {
        phoneExtensionInputControl
    }

    override internal func updateSelection() {
        phoneExtensionInputControl.label = item.value.element.phoneExtension
        phoneExtensionInputControl.flagView.text = item.value.identifier.adyen.countryFlag
    }

    override internal func initialize() {
        super.initialize()
        showsSeparator = false
    }
}
