//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// The interface of the delegate of a text item view.
@_spi(AdyenInternal)
public protocol FormTextItemViewDelegate: AnyObject {
    
    /// Invoked when the text entered in the item view's text field has reached the maximum length.
    ///
    /// - Parameter itemView: The item view in which the maximum length was reached.
    func didReachMaximumLength(in itemView: FormTextItemView<some FormTextItem>)
    
    /// Invoked when the return key in the item view's text field is selected.
    ///
    /// - Parameter itemView: The item view in which the return key was selected.
    func didSelectReturnKey(in itemView: FormTextItemView<some FormTextItem>)
    
}

/// Defines any form text item view.
@_spi(AdyenInternal)
public protocol AnyFormTextItemView: AnyFormItemView {

    /// Delegate text related events.
    var delegate: FormTextItemViewDelegate? { get set }
}

/// A view representing a basic logic of text item.
@_spi(AdyenInternal)
open class FormTextItemView<ItemType: FormTextItem>: FormValidatableValueItemView<String, ItemType>,
    UITextFieldDelegate,
    AnyFormTextItemView {
    
    override public var accessibilityLabelView: UIView? { textField }

    /// Initializes the text item view with theme.
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    public required init(item: ItemType, theme: AdyenTheme) {
        super.init(item: item, theme: theme)

        observe(item.$formattedValue) { [weak self] newValue in
            self?.handleFormattedValueDidChange(newValue)
        }
        
        updateValidation()
        
        addSubview(textStackView)
        configureConstraints()
        
        configure()
    }

    /// Satisfies parent's required initializer. Delegates to main initializer with default theme.
    public required convenience init(item: ItemType) {
        self.init(item: item, theme: .default)
    }

    // MARK: - Configuration

    /// Configures all static styling from theme.
    private func configure() {
        let style = theme.elements.textField

        // Title
        titleLabel.font = style.title.font
        titleLabel.textColor = style.title.color
        titleLabel.textAlignment = style.title.textAlignment

        // Text field
        textField.font = style.text.font
        textField.textColor = style.text.color
        textField.textAlignment = style.text.textAlignment

        // Container
        entryTextStackView.backgroundColor = style.containerColor
        entryTextStackView.layer.borderWidth = style.borderWidth

        // Corner radius
        switch style.cornerRadius {
        case let .fixed(radius):
            entryTextStackView.layer.cornerRadius = radius
        default:
            break
        }

        // Border styling
        updateBorderColor()
    }
    
    override public func reset() {
        textField.text = ""
        item.value = ""
        resetValidationStatus()
    }

    /// Delegate text related events.
    public weak var delegate: FormTextItemViewDelegate?
    
    // MARK: - Stack View
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, entryTextStackView, footerLabel])
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = AdyenUIConstants.contentInsets
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.preservesSuperviewLayoutMargins = true
        stackView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "entryTextStackView")

        return stackView
    }()
    
    private lazy var accessoryStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isHidden = true
        stackView.layoutMargins.bottom = abs(theme.elements.textField.text.font.descender)

        return stackView
    }()
    
    // MARK: - Text Field
    
    public lazy var textField: TextField = {
        let textField = TextField()
        textField.adjustsFontForContentSizeCategory = true
        textField.text = item.value
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

    // MARK: - Accessory view
    
    /// Accessory of the entry text field.
    public var accessory: AccessoryType = .none {
        didSet {
            guard accessory != oldValue else { return }
            changeAccessories()
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
        accessoryView.tintColor = theme.colors.primary
        accessoryStackView.addArrangedSubview(accessoryView)
    }
    
    // MARK: - Private
    
    open func handleFormattedValueDidChange(_ newValue: String) {
        textField.text = newValue
    }
    
    @_spi(AdyenInternal)
    @objc open func textDidChange(textField: UITextField) {
        textField.text = item.textDidChange(value: textField.text ?? "")
        notifyDelegateOfMaxLengthIfNeeded()
    }
    
    @_spi(AdyenInternal)
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Making it available for subclassing
        true
    }
    
    // MARK: - Validation
    
    override public var isValid: Bool {
        if isHidden { return true }
        return super.isValid
    }
    
    override public func showValidation() {
        if isHidden { return }
        super.showValidation()
    }
    
    // MARK: - Editing
    
    override internal func didChangeEditingStatus() {
        updateValidation()
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        textStackView.adyen.anchor(inside: self)
    }
    
    override open var lastBaselineAnchor: NSLayoutYAxisAnchor {
        textField.lastBaselineAnchor
    }
    
    // MARK: - Interaction
    
    override open var canBecomeFirstResponder: Bool {
        if isHidden { return false }
        return textField.canBecomeFirstResponder
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        if isHidden { return false }
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    override open var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didSelectReturnKey(in: self)
        return true
    }
    
    /// This method updates UI according to a validity state.
    /// Subclasses can override this method to stay notified when the text field resigns its first responder status.
    open func textFieldDidEndEditing(_ textField: UITextField) {
        item.isEditing = false
        isEditing = false
        item.triggerValidation(.focusLost)
        updateBorderColor()
        item.onDidEndEditing?()
    }
    
    /// This method hides validation accessories icons.
    /// Subclasses can override this method to stay notified when textField became the first responder.
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        item.isEditing = true
        isEditing = true
        resetValidationStatus()
        updateBorderColor()
        item.onDidBeginEditing?()
    }
    
    open func updateValidation() {
        updateAccessory()
        updateBorderColor()
    }
    
    public func notifyDelegateOfMaxLengthIfNeeded() {
        let maximumLength = item.validator?.maximumLength(for: item.value) ?? .max
        if item.value.count == maximumLength {
            delegate?.didReachMaximumLength(in: self)
        }
    }

    override internal func resetValidationStatus() {
        super.resetValidationStatus()
        updateBorderColor()
        removeAccessoryIfNeeded()
    }

    private func removeAccessoryIfNeeded() {
        if case .customView = accessory { return }
        accessory = .none
    }

    // MARK: - Validation State Changes

    override package func onValidationStateChanged(state: ValidationState) {
        super.onValidationStateChanged(state: state)
        updateAccessory(state: state)
        updateBorderColor(state: state)
    }

    private func updateAccessory() {
        updateAccessory(state: item.validationState)
    }

    private func updateAccessory(state: ValidationState) {
        if state.shouldShowError {
            accessory = .invalid
            return
        }
        
        // Keep custom view unchanged
        if case .customView = accessory { return }
        
        let hasContent = !(textField.text ?? "").isEmpty
        accessory = (hasContent && !isEditing) ? .valid : .none
    }

    // MARK: - Border Styling

    /// Updates the border color based on both editing state and validation state.
    /// Priority: editing (active color) > validation error (error color) > default (normal color)
    private func updateBorderColor() {
        updateBorderColor(state: item.validationState)
    }

    private func updateBorderColor(state: ValidationState) {
        let style = theme.elements.textField
        let borderColor: UIColor
        if isEditing {
            borderColor = style.borderActiveColor
        } else if state.shouldShowError {
            borderColor = style.errorColor
        } else {
            borderColor = style.borderColor
        }
        entryTextStackView.layer.borderColor = borderColor.cgColor
    }
}

@_spi(AdyenInternal)
public extension FormTextItemView {

    enum AccessoryType: Equatable {
        case invalid
        case valid
        case customView(UIView)
        case none
    }

    private final class AccessoryLogo: UIImageView {

        init(success: Bool) {
            let resource = "verification_" + success.description
            let bundle = Bundle.coreInternalResources
            let image = UIImage(named: resource, in: bundle, compatibleWith: nil)
            super.init(image: image)
            
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
