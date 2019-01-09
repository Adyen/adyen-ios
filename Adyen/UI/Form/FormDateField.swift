//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormDateField: FormPickerField {
    
    public init() {
        super.init(customInputView: datePicker)
        refreshDate()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public var date: Date {
        return datePicker.date
    }
    
    // MARK: - Private
    
    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(refreshDate), for: UIControl.Event.valueChanged)
        
        return datePicker
    }()
    
    @objc private func refreshDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        selectedValue = dateFormatter.string(from: date)
    }
}
