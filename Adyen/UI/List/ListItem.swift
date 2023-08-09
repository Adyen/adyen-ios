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
    
    /// The icon to display
    public var icon: Icon?

    /// The trailing text of the item.
    public var trailingText: String?
    
    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?
    
    /// The handler to invoke when the item is deleted.
    public var deletionHandler: ((IndexPath, @escaping Completion<Bool>) -> Void)?
    
    /// The `accessibilityIdentifier` to be used on the `ListItem`
    public var identifier: String?
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - subtitle: The subtitle of the item.
    ///   - icon: The icon of the item.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///   - identifier: The `accessibilityIdentifier` to be used on the `ListItem`
    ///   - selectionHandler: The closure to execute when an item is selected.
    public init(
        title: String,
        subtitle: String? = nil,
        icon: Icon? = nil,
        trailingText: String? = nil,
        style: ListItemStyle = ListItemStyle(),
        identifier: String? = nil,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.trailingText = trailingText
        self.style = style
        self.identifier = identifier
        self.selectionHandler = selectionHandler
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
        hasher.combine(icon)
        hasher.combine(trailingText)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.title == rhs.title && lhs.icon == rhs.icon && lhs.trailingText == rhs.trailingText
    }
}
