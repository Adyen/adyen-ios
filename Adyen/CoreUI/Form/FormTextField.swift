//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Provides a text field to be used in a FormView.
internal class FormTextField: UIControl {
    
    internal init(textFieldClass: UITextField.Type = UITextField.self) {
        self.textFieldClass = textFieldClass
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(borderView)
        
        updateBorderViewBackgroundColor()
        configureConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let borderHeight = 1.0 / UIScreen.main.scale
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3.0),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4.0),
            
            borderView.topAnchor.constraint(equalTo: bottomAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: borderHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Title
    
    /// The title to display above the text field.
    internal var title: String? {
        didSet {
            titleLabel.text = title
            textField.accessibilityLabel = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0)
        titleLabel.textColor = #colorLiteral(red: 0.4431372549, green: 0.4431372549, blue: 0.4431372549, alpha: 1)
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    // MARK: - Text Field
    
    private let textFieldClass: UITextField.Type
    
    fileprivate lazy var textField: UITextField = {
        let textField = self.textFieldClass.init()
        textField.font = UIFont.systemFont(ofSize: 18.0)
        textField.textColor = UIColor.black
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
        
        return textField
    }()
    
    @objc private func textFieldDidBeginEditing() {
        updateBorderViewBackgroundColor()
        
        sendActions(for: .editingDidBegin)
    }
    
    @objc private func textFieldDidEndEditing() {
        updateBorderViewBackgroundColor()
        
        sendActions(for: .editingDidEnd)
    }
    
    @objc private func textFieldTextDidChange() {
        sendActions(for: .editingChanged)
    }
    
    // MARK: - Border View
    
    private lazy var borderView: UIView = {
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        return borderView
    }()
    
    @objc private func updateBorderViewBackgroundColor() {
        if textField.isEditing {
            borderView.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        } else {
            borderView.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        }
    }
    
}

// MARK: - UITextField Properties

internal extension FormTextField {
    
    internal var text: String? {
        get {
            return textField.text
        }
        
        set {
            let attributes: [NSAttributedStringKey: Any] = [
                .font: UIFont.systemFont(ofSize: 18.0),
                .foregroundColor: UIColor.black
            ]
            textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: attributes)
        }
    }
    
    internal var placeholder: String? {
        get {
            return textField.placeholder
        }
        
        set {
            let attributes: [NSAttributedStringKey: Any] = [
                .font: UIFont.systemFont(ofSize: 18.0),
                .foregroundColor: #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
            ]
            textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: attributes)
        }
    }
    
    internal var delegate: UITextFieldDelegate? {
        get {
            return textField.delegate
        }
        
        set {
            textField.delegate = newValue
        }
    }
    
    internal var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        
        set {
            textField.autocapitalizationType = newValue
        }
    }
    
    internal var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        
        set {
            textField.autocorrectionType = newValue
        }
    }
    
    override var accessibilityIdentifier: String? {
        get {
            return nil
        }
        
        set {
            textField.accessibilityIdentifier = newValue
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
}
