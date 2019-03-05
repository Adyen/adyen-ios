//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public protocol FormTextFieldDelegate: class {
    func valueChanged(_ formTextField: FormTextField)
}

/// :nodoc:
open class FormTextField: UIView {
    
    public init() {
        
        super.init(frame: .zero)
        
        textField.delegate = self
        
        backgroundColor = UIColor.clear
        
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(accessoryContainer)
        
        dynamicTypeController.observeDynamicType(for: textField, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)
        
        configureConstraints()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Open
    
    open override var accessibilityIdentifier: String? {
        get {
            return textField.accessibilityIdentifier
        }
        
        set {
            textField.accessibilityIdentifier = newValue
        }
    }
    
    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    // MARK: - Public
    
    public weak var delegate: FormTextFieldDelegate?
    
    /// The title to display above the text field.
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)
                dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.fieldTitleAttributes, textStyle: .footnote)
            } else {
                titleLabel.text = title
            }
            textField.accessibilityLabel = title
        }
    }
    
    public var accessoryView: UIView? {
        didSet {
            if let accessoryView = accessoryView {
                accessoryView.translatesAutoresizingMaskIntoConstraints = false
                accessoryContainer.addSubview(accessoryView)
                accessoryWidthConstraint?.constant = accessoryView.bounds.width + 10
                
                let constraints = [
                    accessoryView.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
                    accessoryView.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.bounds.width),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.bounds.height)
                ]
                
                NSLayoutConstraint.activate(constraints)
                
            } else if let removedView = oldValue {
                removedView.removeFromSuperview()
                accessoryWidthConstraint?.constant = 0
            }
        }
    }
    
    public var validatedValue: String? {
        guard let text = text else {
            return nil
        }
        
        if let validator = validator {
            return validator.isValid(text) ? text : nil
        }
        
        return text
    }
    
    public var validator: Validator?
    public var nextResponderInChain: UIResponder?
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    
    private var accessoryWidthConstraint: NSLayoutConstraint?
    
    private let invalidTextColor: UIColor? = Appearance.shared.formAttributes.invalidTextColor
    private let validTextColor: UIColor? = Appearance.shared.textAttributes[.foregroundColor] as? UIColor
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private lazy var accessoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.defaultTextAttributes = Appearance.shared.textAttributes
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private func configureConstraints() {
        accessoryWidthConstraint = NSLayoutConstraint(item: accessoryContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            accessoryContainer.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 0),
            accessoryContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryContainer.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            accessoryWidthConstraint!,
            
            bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func updateTextColor() {
        if textField.isEditing {
            textField.textColor = validTextColor
        } else {
            textField.textColor = (validatedValue != nil) ? validTextColor : invalidTextColor
        }
    }
    
}

// MARK: - UITextField Properties

/// :nodoc:
public extension FormTextField {
    var text: String? {
        get {
            return textField.text
        }
        
        set {
            let attributes = Appearance.shared.textAttributes
            
            if let unwrappedNewValue = newValue, let formatted = validator?.format(unwrappedNewValue) {
                textField.attributedText = NSAttributedString(string: formatted, attributes: attributes)
            } else {
                textField.attributedText = NSAttributedString(string: newValue ?? "", attributes: attributes)
            }
            
            delegate?.valueChanged(self)
        }
    }
    
    var placeholder: String? {
        get {
            return textField.placeholder
        }
        
        set {
            let attributes = Appearance.shared.formAttributes.placeholderAttributes
            textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: attributes)
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }
    
    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }
    
    var clearButtonMode: UITextField.ViewMode {
        get {
            return textField.clearButtonMode
        }
        set {
            textField.clearButtonMode = newValue
        }
    }
    
}

/// :nodoc:
extension FormTextField: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = validTextColor
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let validator = validator else {
            return
        }
        
        let valid = validator.isValid(text)
        textField.textColor = valid ? validTextColor : invalidTextColor
        
        if !valid {
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            textField.text = ""
            delegate?.valueChanged(self)
            return false
        }
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let isDeleting = (string.count == 0 && range.length == 1)
        guard let validator = validator, !isDeleting else {
            textField.text = newText
            delegate?.valueChanged(self)
            return false
        }
        
        if validator.isMaxLength(text) {
            return false
        }
        
        let formatted = validator.format(newText)
        textField.text = formatted
        delegate?.valueChanged(self)
        
        if validator.isMaxLength(newText) {
            nextResponderInChain?.becomeFirstResponder()
        }
        
        return false
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        delegate?.valueChanged(self)
        return false
    }
    
}
