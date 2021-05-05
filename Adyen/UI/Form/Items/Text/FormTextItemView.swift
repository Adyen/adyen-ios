//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The interface of the delegate of a text item view.
/// :nodoc:
public protocol FormTextItemViewDelegate: AnyObject {
    
    /// Invoked when the text entered in the item view's text field has reached the maximum length.
    ///
    /// - Parameter itemView: The item view in which the maximum length was reached.
    func didReachMaximumLength<T: FormTextItem>(in itemView: FormTextItemView<T>)
    
    /// Invoked when the return key in the item view's text field is selected.
    ///
    /// - Parameter itemView: The item view in which the return key was selected.
    func didSelectReturnKey<T: FormTextItem>(in itemView: FormTextItemView<T>)
    
}

/// Defines any form text item view.
/// :nodoc:
public protocol AnyFormTextItemView: AnyFormItemView {

    /// Delegate text related events.
    var delegate: FormTextItemViewDelegate? { get set }
}

/// A view representing a basic logic of text item.
/// :nodoc:
open class FormTextItemView<ItemType: FormTextItem>: FormValueItemView<String, FormTextItemStyle, ItemType>,
    UITextFieldDelegate,
    AnyFormTextItemView {
    
    /// Initializes the text item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        super.init(item: item)

        bind(item.$placeholder, to: textField, at: \.placeholder)
        
        addSubview(textStackView)
        configureConstraints()
    }

    /// Delegate text related events.
    public weak var delegate: FormTextItemViewDelegate?
    
    // MARK: - Stack View
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, entryTextStackView, alertLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var entryTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, accessoryStackView])
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.preservesSuperviewLayoutMargins = true
        
        return stackView
    }()
    
    private lazy var accessoryStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isHidden = true
        stackView.layoutMargins.bottom = abs(item.style.text.font.descender)
        
        return stackView
    }()
    
    // MARK: - Text Field
    
    public lazy var textField: UITextField = {
        let textField = TextField()
        textField.font = item.style.text.font
        textField.adjustsFontForContentSizeCategory = true
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
        
        return textField
    }()
    
    // MARK: - Alert Label
    
    internal lazy var alertLabel: UILabel = {
        let alertLabel = UILabel(style: item.style.title)
        alertLabel.isAccessibilityElement = false
        alertLabel.text = item.validationFailureMessage
        alertLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "alertLabel") }
        alertLabel.isHidden = true
        
        return alertLabel
    }()
    
    // MARK: - Accessory view
    
    /// Accessory of the entry text field.
    public var accessory: AccessoryType = .none {
        didSet {
            guard accessory != oldValue else { return }
            self.changeAssessories()
        }
    }
    
    private func changeAssessories() {
        accessoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let accessoryView: UIView
        switch accessory {
        case .valid:
            accessoryView = AccessoryLogo(success: true)
        case .invalid:
            accessoryView = AccessoryLogo(success: false)
        case let .customView(view):
            accessoryView = view
        default:
            accessoryStackView.isHidden = true
            return
        }
        
        accessoryStackView.isHidden = false
        accessoryView.tintColor = item.style.icon.tintColor
        accessoryStackView.addArrangedSubview(accessoryView)
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
        sanitizedText = sanitizedText.adyen.truncate(to: maximumLength)
        
        item.value = sanitizedText
        
        if sanitizedText.count == maximumLength {
            delegate?.didReachMaximumLength(in: self)
        }
        
        if let formatter = item.formatter, let newText = newText {
            textField.text = formatter.formattedValue(for: newText)
        }
    }
    
    // MARK: - Validation
    
    /// :nodoc:
    override public func validate() {
        updateValidationStatus(forced: true)
    }
    
    // MARK: - Editing
    
    override internal func didChangeEditingStatus() {
        super.didChangeEditingStatus()
        let customColor = (accessory == .invalid) ? item.style.errorColor : item.style.title.color
        titleLabel.textColor = isEditing ? tintColor : customColor
    }
    
    // MARK: - Layout
    
    /// :nodoc:
    override open func configureSeparatorView() {
        let constraints = [
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureConstraints() {
        textStackView.adyen.anchor(inside: self)
        separatorView.bottomAnchor.constraint(equalTo: accessoryStackView.bottomAnchor, constant: 4).isActive = true
    }
    
    override open var lastBaselineAnchor: NSLayoutYAxisAnchor {
        textField.lastBaselineAnchor
    }
    
    // MARK: - Interaction
    
    /// :nodoc:
    override open var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    /// :nodoc:
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    /// :nodoc:
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    /// :nodoc:
    override open var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    // MARK: - UITextFieldDelegate
    
    /// :nodoc:
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didSelectReturnKey(in: self)
        return true
    }
    
    /// This method updates UI according to a validity state.
    /// Subclasses can override this method to stay notified when the text field resigns its first responder status.
    /// :nodoc:
    open func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
        updateValidationStatus()
    }
    
    /// This method hides validation accessories icons.
    /// Subclasses can override this method to stay notified when textField became the first responder.
    /// :nodoc:
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditing = true
        hideAlertLabel(true)
        if accessory == .valid || accessory == .invalid {
            accessory = .none
        }
    }

    /// :nodoc:
    open func updateValidationStatus(forced: Bool = false) {
        if item.isValid() {
            accessory = .valid
            hideAlertLabel(true)
            highlightSeparatorView(color: tintColor)
            titleLabel.textColor = tintColor
        } else if forced || !(textField.text ?? "").isEmpty {
            accessory = .invalid
            hideAlertLabel(false)
            highlightSeparatorView(color: item.style.errorColor)
            titleLabel.textColor = item.style.errorColor
        }
    }
    
    private func hideAlertLabel(_ hidden: Bool) {
        guard hidden || alertLabel.text != nil else { return }
        alertLabel.adyen.hideWithAnimation(hidden)
    }
}

/// :nodoc:
public extension FormTextItemView {

    /// :nodoc:
    enum AccessoryType: Equatable {
        case invalid
        case valid
        case customView(UIView)
        case none
    }

    /// :nodoc:
    private final class AccessoryLogo: UIImageView {

        /// :nodoc:
        init(success: Bool) {
            let resource = "verification_" + success.description
            let bundle = Bundle.coreInternalResources
            let image = UIImage(named: resource, in: bundle, compatibleWith: nil)
            super.init(image: image)
            
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        /// :nodoc:
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
