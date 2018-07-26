//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// :nodoc:
public class FormField: UIControl {
    public init(textFieldClass: UITextField.Type = UITextField.self) {
        self.textFieldClass = textFieldClass
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
        
        addSubview(titleLabel)
        addSubview(textFieldStackView)
        
        configureConstraints()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        var labelTopOffset: CGFloat = 23 - titleLabel.font.ascender
        labelTopOffset = ceil(labelTopOffset)
        
        var textFieldTopOffset: CGFloat = 24 - abs(titleLabel.font.descender) - (textField.font?.ascender ?? 0.0)
        textFieldTopOffset = ceil(textFieldTopOffset)
        
        var bottomOffset: CGFloat = 13 - abs(textField.font?.descender ?? 0.0)
        bottomOffset = ceil(bottomOffset)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: labelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textFieldStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: textFieldTopOffset),
            textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textFieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bottomAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: bottomOffset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Title
    
    /// The title to display above the text field.
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.fieldTitleAttributes)
            } else {
                titleLabel.text = title
            }
            textField.accessibilityLabel = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    // MARK: - Text Field
    
    private let textFieldClass: UITextField.Type
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        
        return stackView
    }()
    
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
    
    @objc private func textFieldDidBeginEditing() {
        sendActions(for: .editingDidBegin)
    }
    
    @objc private func textFieldDidEndEditing() {
        sendActions(for: .editingDidEnd)
    }
    
    @objc private func textFieldTextDidChange() {
        sendActions(for: .editingChanged)
    }
    
    // MARK: - Accessory View
    
    public var accessoryView: UIView? {
        didSet {
            if let view = accessoryView {
                textFieldStackView.spacing = 4.0
                textFieldStackView.addArrangedSubview(view)
            } else if let removedView = oldValue {
                textFieldStackView.spacing = 0.0
                textFieldStackView.removeArrangedSubview(removedView)
            }
        }
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
