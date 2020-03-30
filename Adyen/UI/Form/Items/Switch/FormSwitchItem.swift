//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which a switch is toggled, producing a boolean value.
/// :nodoc:
public final class FormSwitchItem: FormValueItem {
    
    /// The switch item style.
    public let style: FormSwitchItemStyle
    
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
    /// - Parameter style: The switch item style.
    public init(style: FormSwitchItemStyle = FormSwitchItemStyle()) {
        self.style = style
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
