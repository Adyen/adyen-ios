//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormField: UIControl {
    
    public init(textFieldClass: UITextField.Type = UITextField.self) {
        self.textFieldClass = textFieldClass
        
        super.init(frame: .zero)
        
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
    
    // MARK: - Public
    
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
    
    public lazy var textField: UITextField = {
        let textField = self.textFieldClass.init()
        textField.defaultTextAttributes = Appearance.shared.textAttributes.reduce(into: [:], { $0[$1.key.rawValue] = $1.value })
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        
        return textField
    }()
    
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
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    
    private let textFieldClass: UITextField.Type
    
    private var accessoryWidthConstraint: NSLayoutConstraint?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private lazy var accessoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    @objc private func textFieldDidBeginEditing() {
        sendActions(for: .editingDidBegin)
    }
    
    @objc private func textFieldDidEndEditing() {
        sendActions(for: .editingDidEnd)
    }
    
    @objc private func textFieldTextDidChange() {
        sendActions(for: .editingChanged)
    }
    
}

// MARK: - UITextField Properties

/// :nodoc:
public extension FormField {
    public var text: String? {
        get {
            return textField.text
        }
        
        set {
            let attributes = Appearance.shared.textAttributes
            textField.attributedText = NSAttributedString(string: newValue ?? "", attributes: attributes)
        }
    }
    
    public var placeholder: String? {
        get {
            return textField.placeholder
        }
        
        set {
            if let attributes = Appearance.shared.formAttributes.placeholderAttributes {
                textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: attributes)
            } else {
                textField.placeholder = newValue
            }
        }
    }
    
    public override var accessibilityIdentifier: String? {
        get {
            return textField.accessibilityIdentifier
        }
        
        set {
            textField.accessibilityIdentifier = newValue
        }
    }
    
}
