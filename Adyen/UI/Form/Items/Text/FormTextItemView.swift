//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The interface of the delegate of a text item view.
/// :nodoc:
public protocol FormTextItemViewDelegate: FormValueItemViewDelegate {
    
    /// Invoked when the text entered in the item view's text field has reached the maximum length.
    ///
    /// - Parameter itemView: The item view in which the maximum length was reached.
    func didReachMaximumLength<T: FormTextItem>(in itemView: FormTextItemView<T>)
    
    /// Invoked when the return key in the item view's text field is selected.
    ///
    /// - Parameter itemView: The item view in which the return key was selected.
    func didSelectReturnKey<T: FormTextItem>(in itemView: FormTextItemView<T>)
    
}

/// A view representing a basic logic of text item.
/// :nodoc:
open class FormTextItemView<T: FormTextItem>: FormValueItemView<T>, UITextFieldDelegate where T.ValueType == String {
    
    /// Initializes the text item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: T) {
        super.init(item: item)
        
        addSubview(textStackView)
        
        backgroundColor = item.style.backgroundColor
        
        configureConstraints()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var textDelegate: FormTextItemViewDelegate? {
        return delegate as? FormTextItemViewDelegate
    }
    
    // MARK: - Stack View
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, accessoryStackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.backgroundColor = item.style.backgroundColor
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var accessoryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField])
        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline
        stackView.backgroundColor = item.style.backgroundColor
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = item.style.title.font
        titleLabel.textColor = item.style.title.color
        titleLabel.textAlignment = item.style.title.textAlignment
        titleLabel.backgroundColor = item.style.title.backgroundColor
        titleLabel.text = item.title
        titleLabel.isAccessibilityElement = false
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
        return titleLabel
    }()
    
    // MARK: - Text Field
    
    public lazy var textField: UITextField = {
        let textField = TextField()
        textField.font = item.style.text.font
        textField.textColor = item.style.text.color
        textField.textAlignment = item.style.text.textAlignment
        textField.backgroundColor = item.style.backgroundColor
        setPlaceHolderText(to: textField)
        textField.autocorrectionType = item.autocorrectionType
        textField.autocapitalizationType = item.autocapitalizationType
        textField.keyboardType = item.keyboardType
        textField.returnKeyType = .next
        textField.accessibilityLabel = item.title
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        textField.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "textField") }
        textField.onDidBecomeFirstResponder = { [weak self] in
            self?.isEditing = true
        }
        
        textField.onDidResignFirstResponder = { [weak self] in
            self?.isEditing = false
        }
        
        return textField
    }()
    
    // MARK: - Accessory view
    
    /// Apply state to a Text entry field.
    ///
    /// - Parameter state: state to apply.
    public func setState(_ state: State) {
        if accessoryStackView.arrangedSubviews.count > 1, let last = accessoryStackView.arrangedSubviews.last {
            accessoryStackView.removeArrangedSubview(last)
        }
        
        switch state {
        case .invalid:
            let image = UIImage(named: "verification_false", in: Bundle.internalResources, compatibleWith: nil)
            accessoryStackView.addArrangedSubview(UIImageView(image: image))
        case .valid:
            let image = UIImage(named: "verification_true", in: Bundle.internalResources, compatibleWith: nil)
            accessoryStackView.addArrangedSubview(UIImageView(image: image))
        case .none:
            break
        case let .customLogo(logo):
            accessoryStackView.addArrangedSubview(UIImageView(image: logo))
        case let .customView(view):
            accessoryStackView.addArrangedSubview(view)
        }
    }
    
    // MARK: - Private
    
    private func setPlaceHolderText(to textField: TextField) {
        if let placeholderStyle = item.style.placeholderText, let placeholderText = item.placeholder {
            apply(textStyle: placeholderStyle, to: textField, with: placeholderText)
        } else {
            textField.placeholder = item.placeholder
        }
    }
    
    private func apply(textStyle: TextStyle, to textField: TextField, with placeholderText: String) {
        let attributes = stringAttributes(from: textStyle)
        let attributedString = NSAttributedString(string: placeholderText, attributes: attributes)
        textField.attributedPlaceholder = attributedString
    }
    
    private func stringAttributes(from textStyle: TextStyle) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key.foregroundColor: textStyle.color,
                          NSAttributedString.Key.backgroundColor: textStyle.backgroundColor,
                          NSAttributedString.Key.font: textStyle.font]
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.alignment = item.style.placeholderText?.textAlignment ?? .natural
        if let paragraphStyle = paragraphStyle {
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }
        
        return attributes
    }
    
    @objc private func textDidChange(textField: UITextField) {
        let newText = textField.text
        var sanitizedText = newText.map { item.formatter?.sanitizedValue(for: $0) ?? $0 } ?? ""
        let maximumLength = item.validator?.maximumLength(for: sanitizedText) ?? .max
        sanitizedText = sanitizedText.truncate(to: maximumLength)
        
        item.value = sanitizedText
        
        textDelegate?.didChangeValue(in: self)
        
        if sanitizedText.count == maximumLength {
            textDelegate?.didReachMaximumLength(in: self)
        }
        
        if let formatter = item.formatter, let newText = newText {
            textField.text = formatter.formattedValue(for: newText)
        }
    }
    
    // MARK: - Editing
    
    internal override func didChangeEditingStatus() {
        super.didChangeEditingStatus()
        titleLabel.textColor = isEditing ? tintColor : item.style.title.color
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            textStackView.topAnchor.constraint(equalTo: topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    open override var lastBaselineAnchor: NSLayoutYAxisAnchor {
        return textField.lastBaselineAnchor
    }
    
    // MARK: - Interaction
    
    /// :nodoc:
    open override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    /// :nodoc:
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    /// :nodoc:
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    /// :nodoc:
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textDelegate?.didSelectReturnKey(in: self)
        
        return true
    }
    
}

public extension FormTextItemView {
    enum State {
        case invalid
        case valid
        case customLogo(UIImage?)
        case customView(UIView)
        case none
    }
}

/// A UITextField subclass to override the default UITextField default Accessibility behaviour,
/// specifically the voice over reading of the UITextField.placeholder.
/// So in order to prevent this behaviour,
/// accessibilityValue is overriden to return an empty string in case the text var is nil or empty string.
private final class TextField: UITextField {
    
    private var heightConstraint: NSLayoutConstraint?
    
    var disablePlaceHolderAccessibility: Bool = true
    
    /// Executed when the view resigns as first responder.
    var onDidResignFirstResponder: (() -> Void)?
    
    /// Executed when the view becomes first responder.
    var onDidBecomeFirstResponder: (() -> Void)?
    
    override var accessibilityValue: String? {
        get {
            guard disablePlaceHolderAccessibility else { return super.accessibilityValue }
            if let text = super.text, !text.isEmpty {
                return super.accessibilityValue
            } else {
                return ""
            }
        }
        
        set {
            super.accessibilityValue = newValue
        }
    }
    
    override var font: UIFont? {
        didSet {
            heightConstraint = heightConstraint ?? heightAnchor.constraint(equalToConstant: 0)
            let sizeToFit = sizeThatFits(CGSize(width: bounds.width,
                                                height: UIView.layoutFittingExpandedSize.height))
            heightConstraint?.constant = sizeToFit.height + 1
            heightConstraint?.priority = .defaultHigh
            heightConstraint?.isActive = true
        }
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        onDidResignFirstResponder?()
        return result
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        onDidBecomeFirstResponder?()
        return result
    }
}
