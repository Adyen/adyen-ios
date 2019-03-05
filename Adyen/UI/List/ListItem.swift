//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item in a ListViewController.
internal struct ListItem {
    /// The title of the list item.
    internal var title: String
    
    /// The subtitle of the list item.
    internal var subtitle: String?
    
    /// A URL to an image to optionally display in the list item.
    internal var imageURL: URL?
    
    /// A custom accessibility label for the list item. When none is provided, the title is used.
    internal var accessibilityLabel: String?
    
    /// A boolean value indicating whether a disclosure indicator should be shown.
    internal var showsDisclosureIndicator: Bool
    
    /// The handler to invoke when the item is selected.
    internal var selectionHandler: (() -> Void)?
    
    /// The handler to invoke when the item is deleted.
    internal var deletionHandler: (() -> Void)?
    
    internal init(title: String, subtitle: String? = nil, imageURL: URL? = nil, accessibilityLabel: String? = nil, showsDisclosureIndicator: Bool = false, selectionHandler: (() -> Void)? = nil, deletionHandler: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.accessibilityLabel = accessibilityLabel
        self.showsDisclosureIndicator = showsDisclosureIndicator
        self.selectionHandler = selectionHandler
        self.deletionHandler = deletionHandler
    }
    
}

// MARK: - Hashable & Equatable

extension ListItem: Hashable {
    internal var hashValue: Int {
        return title.hashValue ^ (imageURL?.hashValue ?? 0)
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageURL)
    }
    
    internal static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.title == rhs.title && lhs.imageURL == rhs.imageURL
    }
    
}

/// A section of items in a ListViewController.
internal struct ListSection {
    /// The title of the section.
    internal var title: String?
    
    /// The items inside the section.
    internal var items: [ListItem]
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - items: The items inside the section.
    internal init(title: String? = nil, items: [ListItem]) {
        self.title = title
        self.items = items
    }
    
}
