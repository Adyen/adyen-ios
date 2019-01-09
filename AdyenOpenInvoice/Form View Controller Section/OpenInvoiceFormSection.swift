//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class OpenInvoiceFormSection: FormSection {
    
    // MARK: - Internal
    
    override func addFormElement(_ element: UIView) {
        guard elements.contains(element) == false else {
            return
        }
        
        elements.append(element)
        super.addFormElement(element)
    }
    
    func isValid() -> Bool {
        var valid = true
        elements.forEach { subview in
            if let formTextField = subview as? FormTextField, formTextField.validatedValue == nil {
                valid = valid && false
            } else if let formPickerField = subview as? FormPickerField, formPickerField.selectedValue == nil {
                valid = valid && false
            }
        }
        return valid || isHidden
    }
    
    // MARK: - Private
    
    // Keep track of added elements for validation purposes
    private var elements: [UIView] = []
}
