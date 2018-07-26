//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public class FormPicker: UIControl {
    public init(values: [String]) {
        self.values = values
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(textField)
        
        configureConstraints()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitButton
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.firstBaselineAnchor.constraint(equalTo: topAnchor, constant: 30),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            textField.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 20.0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Values
    
    private var values: [String]
    
    public var selectedValue: String? {
        return textField.text
    }
    
    // MARK: - Title Label
    
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)
            } else {
                titleLabel.text = title
            }
            accessibilityLabel = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    // MARK: - Text Field
    
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
    
    // MARK: - Interaction
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
        
        super.touchesEnded(touches, with: event)
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
