//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// An abstract view representing a validatable value item.
@_spi(AdyenInternal)
open class FormValidatableValueItemView<ValueType, ItemType: FormValidatableValueItem<ValueType>>:
    FormValueItemView<ValueType, FormTextItemStyle, ItemType>,
    AnyFormValidatableValueItemView {
    
    private var itemObserver: Observation?

    public required init(item: ItemType, theme: AdyenTheme) {
        super.init(item: item, theme: theme)
        
        setupObservers()
        updateValidationStatus()
    }

    // MARK: - Views
    
    /// The footer label used to display hints and validation errors
    ///
    /// Shows placeholder hint when valid, validation error when invalid
    internal lazy var footerLabel: UILabel = {
        let footerLabel = UILabel()

        footerLabel.apply(theme.elements.labels.subheadline)
        footerLabel.textColor = theme.colors.textSecondary
        footerLabel.isAccessibilityElement = false
        footerLabel.numberOfLines = 0
        footerLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "footerLabel") }
        footerLabel.isHidden = true
        
        return footerLabel
    }()
    
    // MARK: - Convenience
    
    private func setupObservers() {
        itemObserver = observe(item.publisher) { [weak self] _ in
            self?.updateValidationStatus()
        }
    }
    
    // MARK: - Validation
    
    public var isValid: Bool {
        item.isValid()
    }
    
    public func showValidation() {
        updateValidationStatus(forced: true)
    }
    
    open func updateValidationStatus(forced: Bool = false) {
        guard forced else {
            showHint()
            accessibilityLabelView?.accessibilityLabel = item.title
            return
        }
        if item.isValid() {
            showHint()
            accessibilityLabelView?.accessibilityLabel = item.title
        } else {
            showError(item.validationFailureMessage)
            accessibilityLabelView?.accessibilityLabel = [
                item.title,
                item.validationFailureMessage
            ].compactMap { $0 }.joined(separator: ", ")
        }
    }
    
    private func triggerValidationErrorIfNeeded() {
        guard window != nil,
              let validationStatus = item.validationStatus(),
              let error = validationStatus.validationError else { return }
        item.onDidShowValidationError?(error)
    }
    
    internal func resetValidationStatus() {
        showHint()
        accessibilityLabelView?.accessibilityLabel = item.title
    }

    // MARK: - Footer Label (Hint/Error Display)
    
    package func showHint() {
        guard let placeholder = item.placeholder, !placeholder.isEmpty else {
            footerLabel.isHidden = true
            return
        }
        footerLabel.text = placeholder
        footerLabel.textColor = theme.colors.textSecondary
        footerLabel.isHidden = false
    }
    
    package func showError(_ message: String?) {
        guard let message, !message.isEmpty else {
            showHint()
            return
        }
        footerLabel.text = message
        footerLabel.textColor = theme.colors.destructive
        footerLabel.isHidden = false
        triggerValidationErrorIfNeeded()
    }
}

/// A type-erased form value item view that provides a validation check
@_spi(AdyenInternal)
public protocol AnyFormValidatableValueItemView: AnyFormValueItemView {

    /// Invoke validation check. Performs all necessary UI transformations based on a validation result.
    func showValidation()

    /// Whether or not the value is valid
    var isValid: Bool { get }
}
