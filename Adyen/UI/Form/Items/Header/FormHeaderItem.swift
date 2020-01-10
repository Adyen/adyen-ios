//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a header.
/// :nodoc:
public final class FormHeaderItem: FormItem {
    
    /// Indicates the `FormHeaderItemView` UI styling.
    public let style: Style
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the header.
    public var title: String?
    
    /// Initializes the header item.
    ///
    /// - Parameter style: The `FormHeaderItemView` UI style.
    public init(style: Style = Style()) {
        self.style = style
    }
    
}
