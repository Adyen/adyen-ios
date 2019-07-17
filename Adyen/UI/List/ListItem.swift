//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
/// :nodoc:
public struct ListItem {
    
    /// The title of the item.
    public var title: String
    
    /// The subtitle of the item.
    public var subtitle: String?
    
    /// A URL to an image to display.
    public var imageURL: URL?
    
    /// A boolean value indicating whether a disclosure indicator should be shown in the item's cell.
    public var showsDisclosureIndicator: Bool
    
    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - showsDisclosureIndicator: A boolean value indicating whether a disclosure indicator
    ///                               should be shown in the item's cell.
    public init(title: String, imageURL: URL? = nil, showsDisclosureIndicator: Bool = true, selectionHandler: (() -> Void)? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.showsDisclosureIndicator = showsDisclosureIndicator
        self.selectionHandler = selectionHandler
    }
    
}

// MARK: - Hashable & Equatable

/// :nodoc:
extension ListItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageURL)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.title == rhs.title && lhs.imageURL == rhs.imageURL
    }
    
}
