//
// Copyright (c) Adyen N.V.
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
    
    public required init(item: ItemType, theme: AdyenTheme) {
        super.init(item: item, theme: theme)
        setupValidationObserver()
        updateFooterDisplay(animated: false)
    }

    // MARK: - Views
    
    // Shows placeholder hint when valid, validation error when invalid.
    internal lazy var footerLabel: UILabel = {
        let footerLabel = UILabel()
        footerLabel.apply(theme.elements.labels.subheadline)
        footerLabel.textColor = theme.colors.textSecondary
        footerLabel.isAccessibilityElement = false
        footerLabel.numberOfLines = 0
        footerLabel.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "footerLabel")
        }
        footerLabel.isHidden = true
        return footerLabel
    }()
    
    // MARK: - Validation

    private func setupValidationObserver() {
        observe(item.$shouldShowValidationError) { [weak self] _ in
            self?.updateFooterDisplay(animated: true)
        }
    }

    private func updateFooterDisplay(animated: Bool) {
        if item.shouldShowValidationError {
            displayError(item.validationFailureMessage, animated: animated)
        } else {
            displayHint(animated: animated)
        }
    }
    
    // MARK: - Validation API
    
    public var isValid: Bool {
        item.isValid()
    }
    
    // Called by form to trigger explicit validation (e.g., Pay button).
    // Delegates to updateValidationStatus so subclasses can update their UI (e.g., border color).
    public func showValidation() {
        updateValidationStatus(forced: true)
    }
    
    open func updateValidationStatus(forced: Bool = false) {
        guard forced else {
            accessibilityLabelView?.accessibilityLabel = item.title
            return
        }

        // Forced validation: update the single source of truth
        // Observer will call updateFooterDisplay(animated: true) when this changes
        // In the future, this logic moves to the Item and View listens to Item updates
        item.shouldShowValidationError = !item.isValid()
        updateAccessibility()
        
        triggerValidationErrorCallbackIfNeeded()
    }

    /// Clears validation error state.
    internal func resetValidationStatus() {
        item.shouldShowValidationError = false
        accessibilityLabelView?.accessibilityLabel = item.title
    }

    private func updateAccessibility() {
        if item.shouldShowValidationError {
            accessibilityLabelView?.accessibilityLabel = [
                item.title,
                item.validationFailureMessage
            ].compactMap { $0 }.joined(separator: ", ")
        } else {
            accessibilityLabelView?.accessibilityLabel = item.title
        }
    }

    private func triggerValidationErrorCallbackIfNeeded() {
        guard item.shouldShowValidationError,
              window != nil,
              let validationStatus = item.validationStatus(),
              let error = validationStatus.validationError
        else { return }
        item.onDidShowValidationError?(error)
    }

    // MARK: - Footer Display (Private)

    /// Displays the placeholder hint in the footer.
    private func displayHint(animated: Bool) {
        guard let placeholder = item.placeholder, !placeholder.isEmpty else {
            footerLabel.adyen.hide(animationKey: Constants.footerAnimationKey, hidden: true, animated: animated)
            return
        }
        footerLabel.text = placeholder
        footerLabel.textColor = theme.colors.textSecondary
        footerLabel.adyen.hide(animationKey: Constants.footerAnimationKey, hidden: false, animated: animated)
    }

    /// Displays the error message in the footer.
    private func displayError(_ message: String?, animated: Bool) {
        guard let message, !message.isEmpty else {
            displayHint(animated: animated)
            return
        }
        footerLabel.text = message
        footerLabel.textColor = theme.colors.destructive
        footerLabel.adyen.hide(animationKey: Constants.footerAnimationKey, hidden: false, animated: animated)
    }

    // MARK: - Package API (for subclasses that need direct control)

    package func showHint() {
        displayHint(animated: true)
    }

    package func showError(_ message: String?) {
        displayError(message, animated: true)
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

private enum Constants {
    static let footerAnimationKey = "footerLabel_visibility"
}
