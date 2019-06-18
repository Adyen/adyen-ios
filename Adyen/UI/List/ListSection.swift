//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A section of items in a ListViewController.
/// :nodoc:
public struct ListSection {
    /// The title of the section.
    public var title: String?
    
    /// The items inside the section.
    public var items: [ListItem]
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - items: The items inside the section.
    public init(title: String? = nil, items: [ListItem]) {
        self.title = title
        self.items = items
    }
    
}
