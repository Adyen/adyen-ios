//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// An selectable item in a form in which holds a generic value.
@_spi(AdyenInternal)
open class FormSelectableValueItem<ValueType: Equatable>: FormValidatableValueItem<ValueType> {
    
    /// A closure that will be invoked when the item is selected.
    public var selectionHandler: () -> Void
    
    /// The formatted value to show in the view
    @AdyenObservable(nil) public var formattedValue: String?
    
    public init(
        value: ValueType,
        style: FormTextItemStyle,
        placeholder: String
    ) {
        selectionHandler = {
            AdyenAssertion.assertionFailure(message: "'selectionHandler' needs to be provided on '\(String(describing: Self.self))'")
        }
        
        super.init(value: value, style: style)
        
        self.placeholder = placeholder
    }
}
