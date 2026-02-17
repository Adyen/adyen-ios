//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

package enum ValidationTrigger {
    case focusLost
    case explicit
}

package enum ValidationState: Equatable {
    case initial
    case valid
    case invalid(String)
    
    package var shouldShowError: Bool {
        switch self {
        case .invalid: true
        case .initial, .valid: false
        }
    }
    
    package var errorMessage: String? {
        switch self {
        case let .invalid(message): message
        case .initial, .valid: nil
        }
    }
}

/// A validatable item in a form in which holds a generic value.
@_spi(AdyenInternal)
open class FormValidatableValueItem<ValueType: Equatable>: FormValueItem<ValueType, FormTextItemStyle>, ValidatableFormItem {
    
    /// The placeholder text shown as a hint below the input field.
    @AdyenObservable(nil) public var placeholder: String?
    
    /// A message that is displayed when validation fails. Observable.
    @AdyenObservable(nil) public var validationFailureMessage: String?

    /// Single source of truth for validation state.
    /// Views observe this property to update their UI reactively.
    @AdyenObservable(.initial) package var validationState: ValidationState

    /// Observation manager that automatically cleans up handlers on deinit.
    private let observationManager = ObservationManager()
    
    /// Closure that is triggered when there is a validation error.
    public var onDidShowValidationError: ((ValidationError) -> Void)?
    
    override internal init(value: ValueType, style: FormTextItemStyle) {
        super.init(value: value, style: style)

        _ = observationManager.observe($validationState) { [weak self] newState in
            self?.notifyOnValidationError(for: newState)
        }
    }

    public func isValid() -> Bool {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return false
    }
    
    /// Checks the current validation status of the item.
    public func validationStatus() -> ValidationStatus? {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return nil
    }
    
    /// Checks if the value is considered empty.
    public func isEmpty() -> Bool {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return false
    }

    /// Resets validation state to initial (clears any error).
    package func resetValidation() {
        validationState = .initial
    }
    
    package func triggerValidation(_ trigger: ValidationTrigger) {
        if trigger == .focusLost, isEmpty() {
            return
        }
        let newState: ValidationState = isValid() ? .valid : .invalid(validationFailureMessage ?? "")
        validationState = newState
    }

    // MARK: - Private
    
    private func notifyOnValidationError(for state: ValidationState) {
        guard case .invalid = state,
              let validationStatus = validationStatus(),
              let error = validationStatus.validationError
        else { return }
        
        onDidShowValidationError?(error)
    }
}
