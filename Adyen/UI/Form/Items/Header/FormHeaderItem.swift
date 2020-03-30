//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a header.
/// :nodoc:
public final class FormHeaderItem: FormItem {
    
    /// The form header style.
    public let style: FormHeaderStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the header.
    public var title: String?
    
    /// Initializes the header item.
    ///
    /// - Parameter style: The form header style.
    public init(style: FormHeaderStyle = FormHeaderStyle()) {
        self.style = style
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
