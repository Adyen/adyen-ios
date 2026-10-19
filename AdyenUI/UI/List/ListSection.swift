//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The editing style.
package enum EditingStyle {
    case delete
    case none
}

/// A section of items in a ListViewController.
package struct ListSection: Hashable {

    /// The title of the section.
    package let header: ListSectionHeader?

    /// The items inside the section.
    package private(set) var items: [ListItem]

    /// The footer title of the section.
    package let footer: ListSectionFooter?

    package var isEditable: Bool {
        header?.editingStyle != EditingStyle.none
    }
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - header: The section header.
    ///   - items: The items inside the section.
    ///   - footer: The section footer.
    package init(
        header: ListSectionHeader? = nil,
        items: [ListItem],
        footer: ListSectionFooter? = nil
    ) {
        self.header = header
        self.items = items
        self.footer = footer
        self.identifier = UUID().uuidString
    }
    
    private let identifier: String
    
    internal mutating func deleteItem(index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(header)
        hasher.combine(footer)
    }
    
    package static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        lhs.header == rhs.header &&
            lhs.footer == rhs.footer &&
            lhs.identifier == rhs.identifier
    }
    
}

/// A list section header.
package struct ListSectionHeader: Hashable {

    /// The header title.
    package var title: String

    /// The header style.
    package var style: ListSectionHeaderStyle

    /// The editing style.
    package var editingStyle: EditingStyle = .none

    /// - Parameters:
    ///   - title: The header title
    ///   - style: The UI style.
    package init(title: String, editingStyle: EditingStyle = .none, style: ListSectionHeaderStyle) {
        self.title = title
        self.editingStyle = editingStyle
        self.style = style
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(editingStyle)
    }
    
    package static func == (lhs: ListSectionHeader, rhs: ListSectionHeader) -> Bool {
        lhs.title == rhs.title && lhs.editingStyle == rhs.editingStyle
    }
}

/// A list section footer.
package struct ListSectionFooter: Hashable {

    /// The footer title.
    package var title: String

    /// The footer style.
    package var style: ListSectionFooterStyle

    /// - Parameters:
    ///   - title: The footer title
    ///   - style: The UI style.
    package init(title: String, style: ListSectionFooterStyle) {
        self.title = title
        self.style = style
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    package static func == (lhs: ListSectionFooter, rhs: ListSectionFooter) -> Bool {
        lhs.title == rhs.title
    }
}
