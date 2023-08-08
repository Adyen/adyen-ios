//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class FormPickerItemView: FormSelectableValueItemView<FormPickerElement, FormPickerItem> {
    
    internal required init(item: FormPickerItem) {
        super.init(item: item)
        item.selectionHandler = { [weak self] in
            
            let topPresenter = self?.item.presenter
            
            let pickerViewController = FormPickerSearchViewController(
                localizationParameters: item.localizationParameters,
                title: item.title,
                options: item.selectableValues
            ) { [weak topPresenter] selectedItem in
                item.value = selectedItem
                topPresenter?.dismissViewController(animated: true)
            }
            
            item.presenter?.presentViewController(pickerViewController, animated: true)
        }
    }
    
    override internal func showValidation() {
        if item.isValid() {
            updateValidationStatus(forced: false)
        } else {
            super.validate()
        }
    }
    
    override internal func reset() {
        item.resetValue()
        resetValidationStatus()
    }
}
