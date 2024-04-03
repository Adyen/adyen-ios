//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A validatable item in a form in which holds a generic value.
@_spi(AdyenInternal)
open class FormValidatableValueItem<ValueType: Equatable>: FormValueItem<ValueType, FormTextItemStyle>, ValidatableFormItem {
    
    /// A message that is displayed when validation fails. Observable.
    @AdyenObservable(nil) public var validationFailureMessage: String?
    
    public func isValid() -> Bool {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return false
    }
}
