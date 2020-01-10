//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which a switch is toggled, producing a boolean value.
/// :nodoc:
open class FormSwitchItem: FormValueItem {
    
    /// Indicates the `FormSwitchItemView` UI styling.
    public let style: Style
    
    /// :nodoc:
    public var identifier: String?
    
    /// The type of value entered in the item.
    public typealias ValueType = Bool
    
    /// The title displayed next to the switch.
    public var title: String?
    
    /// The current value of the switch.
    public var value = false
    
    /// Initializes the switch item.
    ///
    /// - Parameter style: The `FormSwitchItemView` UI style.
    public init(style: Style = Style()) {
        self.style = style
    }
    
}
