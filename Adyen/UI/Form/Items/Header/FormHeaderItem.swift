//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a header.
/// :nodoc:
public final class FormHeaderItem: FormItem {
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the header.
    public var title: String?
    
    /// Initializes the header item.
    public init() {}
    
}
