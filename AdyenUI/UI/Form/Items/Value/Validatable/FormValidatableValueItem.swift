//
// Copyright (c) Adyen N.V.
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
    
    /// Whether error UI should be displayed.
    var shouldShowError: Bool {
        switch self {
        case .invalid: true
        case .initial, .valid: false
        }
    }
    
    var errorMessage: String? {
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
    @AdyenUIObservable(.initial) package var validationState: ValidationState
    
    /// Backward-compatible computed property for checking if error should be shown.
    public var shouldShowValidationError: Bool {
        get { validationState.shouldShowError }
        set { validationState = newValue ? .invalid(validationFailureMessage ?? "") : .initial }
    }
    
    /// Tracks whether the field is currently being edited.
    /// Views update this when focus changes, allowing reactive UI updates.
    @AdyenObservable(false) public var isEditing: Bool
    
    /// Closure that is triggered when there is a validation error.
    public var onDidShowValidationError: ((ValidationError) -> Void)?
    
    public func isValid() -> Bool {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return false
    }
    
    /// Checks the current validation status of the item.
    public func validationStatus() -> ValidationStatus? {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return nil
    }

    /// Triggers validation based on the given trigger type.
    /// - Parameter trigger: The validation trigger.
    package func triggerValidation(_ trigger: ValidationTrigger) {
        if trigger == .focusLost, let stringValue = value as? String, stringValue.isEmpty {
            return
        }
        validationState = isValid() ? .valid : .invalid(validationFailureMessage ?? "")
    }
}
