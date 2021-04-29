//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which a switch is toggled, producing a boolean value.
/// :nodoc:
public final class FormSwitchItem: FormValueItem<Bool, FormSwitchItemStyle> {
    
    /// Initializes the switch item.
    ///
    /// - Parameter style: The switch item style.
    public init(style: FormSwitchItemStyle = FormSwitchItemStyle()) {
        super.init(value: false, style: style)
    }
    
    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
