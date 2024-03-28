//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An selectable item in a form in which holds a generic value.
@_spi(AdyenInternal)
open class FormSelectableValueItem<ValueType: Equatable>: FormValidatableValueItem<ValueType> {
    
    /// The placeholder of the item.
    public let placeholder: String
    
    /// A closure that will be invoked when the item is selected.
    public var selectionHandler: () -> Void
    
    /// The formatted value to show in the view
    @AdyenObservable(nil) public var formattedValue: String?
    
    public init(
        value: ValueType,
        style: FormTextItemStyle,
        placeholder: String
    ) {
        self.placeholder = placeholder
        
        selectionHandler = {
            AdyenAssertion.assertionFailure(message: "'selectionHandler' needs to be provided on '\(String(describing: Self.self))'")
        }
        
        super.init(value: value, style: style)
    }
}
