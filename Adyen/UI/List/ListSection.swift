//
// Copyright (c) 2021 Adyen N.V.
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

    /// The footer title of the section.
    public var footerTitle: String?
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - items: The items inside the section.
    public init(title: String? = nil, items: [ListItem], footerTitle: String? = nil) {
        self.title = title
        self.items = items
        self.footerTitle = footerTitle
    }
    
}
