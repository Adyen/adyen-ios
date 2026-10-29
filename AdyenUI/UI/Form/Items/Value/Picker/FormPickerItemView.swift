//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

package class FormPickerItemView<Value: FormPickable>: FormSelectableValueItemView<Value, FormPickerItem<Value>> {

    internal required init(item: FormPickerItem<Value>, theme: CheckoutTheme) {
        super.init(item: item, theme: theme)
        item.selectionHandler = { [weak self] in
            
            let topPresenter = self?.item.presenter
            weak var pickerScreen: UIViewController?            
            let pickerViewController = FormPickerSearchViewController(
                localizationParameters: item.localizationParameters,
                configuration: item.configuration,
                theme: theme,
                options: item.selectableValues,
                selectedOption: item.value
            ) { [weak topPresenter] selectedItem in
                item.value = selectedItem
                guard let pickerScreen else { return }
                topPresenter?.dismissViewController(pickerScreen, animated: true)
            }
            pickerScreen = pickerViewController
            
            item.presenter?.presentViewController(pickerViewController, animated: true)
        }
    }
}
