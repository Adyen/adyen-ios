//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

package class FormPickerItemView<Value: FormPickable>: FormSelectableValueItemView<Value, FormPickerItem<Value>> {

    internal required init(item: FormPickerItem<Value>, theme: AdyenTheme) {
        super.init(item: item, theme: theme)
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
    
    override package func showValidation() {
        if item.isValid() {
            updateValidation()
        } else {
            super.showValidation()
        }
    }
    
    override package func reset() {
        item.resetValue()
        resetValidationStatus()
    }
}
