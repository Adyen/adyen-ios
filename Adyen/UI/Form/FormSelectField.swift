//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormSelectField: FormPickerField {
    
    public init(values: [String]) {
        self.values = values
        
        let pickerView = UIPickerView()
        super.init(customInputView: pickerView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        selectedValue = values.first
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private var values: [String]
}

/// :nodoc:
extension FormSelectField: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = values[row]
    }
}
