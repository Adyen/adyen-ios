//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public enum EditinStyle {
    case delete
    case none
}

/// A section of items in a ListViewController.
/// :nodoc:
public struct ListSection {
    
    /// Section allowed editing.
    public let editingStyle: EditinStyle
    
    /// The title of the section.
    public let header: ListSectionHeader?

    /// The items inside the section.
    public private(set) var items: [ListItem]

    /// The footer title of the section.
    public let footer: ListSectionFooter?
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - header: The section header.
    ///   - items: The items inside the section.
    ///   - footer: The section footer.
    ///   - editingStyle: The section editing style.
    public init(header: ListSectionHeader? = nil,
                items: [ListItem],
                footer: ListSectionFooter? = nil,
                editingStyle: EditinStyle = .none) {
        self.header = header
        self.items = items
        self.footer = footer
        self.editingStyle = editingStyle
    }
    
    internal mutating func deleteItem(index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }
    
}

/// A list section header.
/// :nodoc:
public struct ListSectionHeader {

    /// The header title.
    /// :nodoc:
    public var title: String

    /// The header style.
    /// :nodoc:
    public var style: ListSectionHeaderStyle

    /// :nodoc:
    /// - Parameters:
    ///   - title: The header title
    ///   - style: The UI style.
    public init(title: String, style: ListSectionHeaderStyle) {
        self.title = title
        self.style = style
    }
}

/// A list section footer.
/// :nodoc:
public struct ListSectionFooter {

    /// The footer title.
    /// :nodoc:
    public var title: String

    /// The footer style.
    /// :nodoc:
    public var style: ListSectionFooterStyle

    /// :nodoc:
    /// - Parameters:
    ///   - title: The footer title
    ///   - style: The UI style.
    public init(title: String, style: ListSectionFooterStyle) {
        self.title = title
        self.style = style
    }
}
