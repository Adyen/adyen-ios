//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
@_spi(AdyenInternal)
public class ListItem: FormItem {

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
    
    /// Whether or not to show the icon at all
    public let showsIcon: Bool
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - subtitle: The subtitle of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///   - selectionHandler: The closure to execute when an item is selected.
    ///   - canModifyIcon: The flag to indicate that image could be tampered.
    ///   - showsIcon: Whether or not to show the icon at all.
    public init(
        title: String,
        subtitle: String? = nil,
        imageURL: URL? = nil,
        trailingText: String? = nil,
        style: ListItemStyle = ListItemStyle(),
        selectionHandler: (() -> Void)? = nil,
        canModifyIcon: Bool = true,
        showsIcon: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.trailingText = trailingText
        self.style = style
        self.selectionHandler = selectionHandler
        self.canModifyIcon = canModifyIcon
        self.showsIcon = showsIcon
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

// MARK: - Hashable & Equatable

@_spi(AdyenInternal)
extension ListItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageURL)
        hasher.combine(trailingText)
        hasher.combine(showsIcon)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.title == rhs.title && lhs.imageURL == rhs.imageURL && lhs.trailingText == rhs.trailingText && lhs.showsIcon == rhs.showsIcon
    }
    
}
