//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
/// :nodoc:
public struct ListItem {
    
    /// Indicates the `ListItemView` UI styling.
    public let style: Style
    
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
    
    /// An identifier for the `ListItem`,
    /// that is set to the `ListItemView.accessibilityIdentifier`.
    public var identifier: String?
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - style: The `ListItemView` UI styling.
    ///   - showsDisclosureIndicator: A boolean value indicating whether a disclosure indicator
    ///                               should be shown in the item's cell.
    ///   - selectionHandler: The closure to execute when an item is selected.
    public init(title: String,
                imageURL: URL? = nil,
                style: Style = Style(),
                showsDisclosureIndicator: Bool = true,
                selectionHandler: (() -> Void)? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.style = style
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
