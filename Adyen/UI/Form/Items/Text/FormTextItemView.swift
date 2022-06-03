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
        observe(item.$formattedValue) { [weak self] newValue in
            self?.textField.text = newValue
            self?.updateValidationStatus()
        }
        
        updateValidationStatus()
        
        addSubview(textStackView)
        configureConstraints()
        
        observe(item.$validationFailureMessage) { [weak self] newValue in
            self?.alertLabel.text = newValue
        }
    }
    
    /// :nodoc:
    override public func reset() {
        item.value = ""
        resetValidationStatus()
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
    
    public lazy var textField: TextField = {
        let textField = TextField()
        textField.font = item.style.text.font
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = item.style.text.color
        textField.textAlignment = item.style.text.textAlignment
        textField.backgroundColor = item.style.backgroundColor
        textField.text = item.value
        textField.apply(placeholderText: item.placeholder, with: item.style.placeholderText)
        textField.autocorrectionType = item.autocorrectionType
        textField.autocapitalizationType = item.autocapitalizationType
        textField.keyboardType = item.keyboardType
        textField.returnKeyType = .next
        textField.delegate = self
        textField.textContentType = item.contentType
        
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        textField.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "textField") }
        
        return textField
    }()
    
    // MARK: - Alert Label
    
    internal lazy var alertLabel: UILabel = {
        let alertLabel = UILabel(style: item.style.title)
        alertLabel.textColor = item.style.errorColor
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
            self.changeAccessories()
        }
    }
    
    private func changeAccessories() {
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
    
    @objc private func textDidChange(textField: UITextField) {
        textField.text = item.textDidChange(value: textField.text ?? "")
        notifyDelegateOfMaxLengthIfNeeded()
    }
    
    // MARK: - Validation
    
    /// :nodoc:
    override public func validate() {
        guard !isHidden else { return }
        updateValidationStatus(forced: true)
    }
    
    // MARK: - Editing
    
    override internal func didChangeEditingStatus() {
        updateValidationStatus()
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
    }
    
    /// This method hides validation accessories icons.
    /// Subclasses can override this method to stay notified when textField became the first responder.
    /// :nodoc:
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditing = true
    }

    /// :nodoc:
    open func updateValidationStatus(forced: Bool = false) {
        let textFieldNotEmpty = textField.text.map(\.isEmpty) == false
        // if validation check is allowed during editing, ignore editing check
        let forceShowValidationStatus = (forced || textFieldNotEmpty)
            && (item.allowsValidationWhileEditing || !isEditing)
        if item.isValid(), forceShowValidationStatus {
            accessory = .valid
            hideAlertLabel(true)
            highlightSeparatorView(color: tintColor)
            titleLabel.textColor = tintColor
            textField.accessibilityLabel = item.title
        } else if forceShowValidationStatus {
            accessory = .invalid
            hideAlertLabel(false)
            highlightSeparatorView(color: item.style.errorColor)
            titleLabel.textColor = item.style.errorColor
            textField.accessibilityLabel = item.validationFailureMessage
        } else {
            removeAccessoryIfNeeded()
            hideAlertLabel(true)
            isEditing ? highlightSeparatorView(color: tintColor) : unhighlightSeparatorView()
            titleLabel.textColor = defaultTitleColor
            textField.accessibilityLabel = item.title
        }
    }
    
    /// :nodoc:
    public func notifyDelegateOfMaxLengthIfNeeded() {
        let maximumLength = item.validator?.maximumLength(for: item.value) ?? .max
        if item.value.count == maximumLength {
            delegate?.didReachMaximumLength(in: self)
        }
    }

    /// :nodoc:
    internal func resetValidationStatus() {
        removeAccessoryIfNeeded()
        hideAlertLabel(true, animated: false)
        unhighlightSeparatorView()
        titleLabel.textColor = defaultTitleColor
    }

    private func removeAccessoryIfNeeded() {
        if case .customView = accessory {
            /* Do nothing */
        } else {
            accessory = .none
        }
    }
    
    private func hideAlertLabel(_ hidden: Bool, animated: Bool = true) {
        guard hidden || alertLabel.text != nil else { return }
        alertLabel.adyen.hide(animationKey: "hide_alertLabel", hidden: hidden, animated: animated)
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
