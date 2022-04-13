//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which a switch is toggled, producing a boolean value.
/// :nodoc:
public final class FormToggleItem: FormValueItem<Bool, FormToggleItemStyle>, Hidable {

    /// :nodoc:
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    /// Initializes the switch item.
    ///
    /// - Parameter style: The switch item style.
    public init(style: FormToggleItemStyle = FormToggleItemStyle()) {
        super.init(value: false, style: style)
    }
    
    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
