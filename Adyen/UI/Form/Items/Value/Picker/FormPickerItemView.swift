//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal class FormPickerItemView: FormSelectableValueItemView<FormPickerElement, FormPickerItem> {
    
    private var shouldBecomeFirstResponder: Bool = false
    
    private var viewController: UIViewController? {
        window?.rootViewController?.adyen.topPresenter
    }
    
    internal required init(item: FormPickerItem) {
        super.init(item: item)
        item.selectionHandler = { [weak self] in
            
            let topPresenter = self?.viewController
            
            let pickerViewController = FormPickerSearchViewController(
                localizationParameters: item.localizationParameters,
                title: item.title,
                options: item.selectableValues
            ) { [weak topPresenter] selectedItem in
                item.value = selectedItem
                topPresenter?.dismiss(animated: true)
            }
            
            // TODO: Alex - Align with Design Team
            
//            if #available(iOS 15.0, *) {
//                if let presentationController = pickerViewController.presentationController as? UISheetPresentationController {
//                    presentationController.prefersGrabberVisible = true
//                    presentationController.detents = [.medium(), .large()]
//                }
//            }
            
            topPresenter?.present(pickerViewController, animated: true)
        }
    }
    
    override internal func reset() {
        item.resetValue()
        resetValidationStatus()
    }
}
