//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormPicker: UIControl {
    
    public init(values: [String]) {
        self.values = values
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(textField)
        
        dynamicTypeController.observeDynamicType(for: textField, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)
        
        configureConstraints()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIResponder
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
        
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: - Public
    
    public var selectedValue: String? {
        return textField.text
    }
    
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)
                
                dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.fieldTitleAttributes, textStyle: .footnote)
            } else {
                titleLabel.text = title
            }
            accessibilityLabel = title
        }
    }
    
    // MARK: - Private
    
    private var values: [String]
    
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private lazy var textField: FormPickerTextField = {
        let textField = FormPickerTextField()
        textField.defaultTextAttributes = Appearance.shared.textAttributes.reduce(into: [:], { $0[$1.key.rawValue] = $1.value })
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = values.first
        textField.delegate = self
        textField.textAlignment = .right
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField.inputView = pickerView
        
        return textField
    }()
    
    private func configureConstraints() {
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17),
            
            textField.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 20.0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

/// :nodoc:
extension FormPicker: UIPickerViewDelegate, UIPickerViewDataSource {
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
        textField.text = values[row]
    }
}

/// :nodoc:
extension FormPicker: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

private class FormPickerTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
