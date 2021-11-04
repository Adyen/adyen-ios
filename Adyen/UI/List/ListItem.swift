//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
/// :nodoc:
public class ListItem: FormItem {

    /// :nodoc:
    public var subitems: [FormItem] = []
    
    /// The list item style.
    public let style: ListItemStyle
    
    /// The title of the item.
    public var title: String
    
    /// The subtitle of the item.
    public var subtitle: String?
    
    /// A URL to an image to display.
    public var imageURL: URL?

    /// The trailing text of the item.
    public var trailingText: String?
    
    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?
    
    /// The handler to invoke when the item is deleted.
    public var deletionHandler: ((IndexPath, @escaping Completion<Bool>) -> Void)?
    
    /// An identifier for the `ListItem`,
    /// that is set to the `ListItemView.accessibilityIdentifier`.
    public var identifier: String?

    /// The flag to indicate if an icon is a custom image that should not be tempered.
    public let canModifyIcon: Bool
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///                               should be shown in the item's cell.
    ///   - selectionHandler: The closure to execute when an item is selected.
    ///   - canModifyIcon: The flag to indicate that image could be tampered.
    public init(title: String,
                imageURL: URL? = nil,
                trailingText: String? = nil,
                style: ListItemStyle = ListItemStyle(),
                selectionHandler: (() -> Void)? = nil,
                canModifyIcon: Bool = true) {
        self.title = title
        self.imageURL = imageURL
        self.trailingText = trailingText
        self.style = style
        self.selectionHandler = selectionHandler
        self.canModifyIcon = canModifyIcon
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

// MARK: - Hashable & Equatable

/// :nodoc:
extension ListItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageURL)
        hasher.combine(trailingText)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.title == rhs.title && lhs.imageURL == rhs.imageURL && lhs.trailingText == rhs.trailingText
    }
    
}
