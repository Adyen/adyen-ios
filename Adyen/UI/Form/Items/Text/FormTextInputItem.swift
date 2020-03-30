//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item for plain text input
/// :nodoc:
public final class FormTextInputItem: FormTextItem {
    
    /// Inititate new instance of `FormTextInputItem`
    /// - Parameter style: The `FormTextItemStyle` UI style.
    public init(style: FormTextItemStyle = FormTextItemStyle()) {
        self.style = style
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
