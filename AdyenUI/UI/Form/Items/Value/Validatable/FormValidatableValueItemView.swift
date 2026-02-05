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
        updateFooterDisplay(state: item.validationState, animated: false)
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
        observe(item.$validationState) { [weak self] state in
            self?.onValidationStateChanged(state: state)
        }
    }

    package func onValidationStateChanged(state: ValidationState) {
        updateFooterDisplay(state: state, animated: true)
        updateAccessibility(state: state)
    }

    private func updateFooterDisplay(state: ValidationState, animated: Bool) {
        let newText: String?
        let newColor: UIColor
        let shouldBeVisible: Bool
        
        if let errorMessage = state.errorMessage, !errorMessage.isEmpty {
            newText = errorMessage
            newColor = theme.colors.destructive
            shouldBeVisible = true
        } else if let placeholder = item.placeholder, !placeholder.isEmpty {
            newText = placeholder
            newColor = theme.colors.textSecondary
            shouldBeVisible = true
        } else {
            newText = nil
            newColor = theme.colors.textSecondary
            shouldBeVisible = false
        }
        
        updateFooter(text: newText, color: newColor, visible: shouldBeVisible, animated: animated)
    }

    // MARK: - Validation API

    public var isValid: Bool {
        item.isValid()
    }

    // Called by form to trigger explicit validation (e.g., Pay button).
    public func showValidation() {
        item.triggerValidation(.explicit)
        triggerValidationErrorCallbackIfNeeded()
    }

    /// Clears validation error state.
    internal func resetValidationStatus() {
        item.resetValidation()
    }

    private func updateAccessibility(state: ValidationState) {
        if let errorMessage = state.errorMessage {
            accessibilityLabelView?.accessibilityLabel = [
                item.title,
                errorMessage
            ].compactMap { $0 }.joined(separator: ", ")
        } else {
            accessibilityLabelView?.accessibilityLabel = item.title
        }
    }

    private func triggerValidationErrorCallbackIfNeeded() {
        guard item.validationState.shouldShowError,
              window != nil,
              let validationStatus = item.validationStatus(),
              let error = validationStatus.validationError
        else { return }
        item.onDidShowValidationError?(error)
    }

    // MARK: - Package API (for subclasses that need direct control)

    package func showHint() {
        let newText = item.placeholder
        let newColor = theme.colors.textSecondary
        let shouldBeVisible = newText?.isEmpty == false
        
        updateFooter(text: newText, color: newColor, visible: shouldBeVisible, animated: true)
    }

    package func showError(_ message: String?) {
        guard let message, !message.isEmpty else {
            showHint()
            return
        }
        updateFooter(text: message, color: theme.colors.destructive, visible: true, animated: true)
    }
    
    private func updateFooter(text: String?, color: UIColor, visible: Bool, animated: Bool) {
        let contentChanged = footerLabel.text != text || footerLabel.textColor != color
        let wasVisible = !footerLabel.isHidden
        
        // Set state immediately for synchronous access (tests)
        footerLabel.text = text
        footerLabel.textColor = color
        
        if animated, visible, wasVisible, contentChanged {
            // Crossfade: visible -> visible with different content
            UIView.transition(
                with: footerLabel,
                duration: 0.2,
                options: [.transitionCrossDissolve, .beginFromCurrentState],
                animations: nil
            )
        } else if animated {
            footerLabel.adyen.hide(animationKey: Constants.footerAnimationKey, hidden: !visible, animated: true)
        } else {
            footerLabel.adyen.hide(animationKey: Constants.footerAnimationKey, hidden: !visible, animated: false)
        }
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
