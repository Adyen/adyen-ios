//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The editing style.
@_spi(AdyenInternal)
public enum EditingStyle {
    case delete
    case none
}

/// A section of items in a ListViewController.
@_spi(AdyenInternal)
public struct ListSection: Hashable {
    
    /// The title of the section.
    public let header: ListSectionHeader?

    /// The items inside the section.
    public private(set) var items: [ListItem]

    /// The footer title of the section.
    public let footer: ListSectionFooter?
    
    public var isEditable: Bool {
        header?.editingStyle != EditingStyle.none
    }
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - header: The section header.
    ///   - items: The items inside the section.
    ///   - footer: The section footer.
    public init(header: ListSectionHeader? = nil,
                items: [ListItem],
                footer: ListSectionFooter? = nil) {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(header)
        hasher.combine(footer)
    }
    
    public static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        lhs.header == rhs.header &&
            lhs.footer == rhs.footer &&
            lhs.identifier == rhs.identifier
    }
    
}

/// A list section header.
@_spi(AdyenInternal)
public struct ListSectionHeader: Hashable {

    /// The header title.
    public var title: String

    /// The header style.
    public var style: ListSectionHeaderStyle
    
    /// The editing style.
    public var editingStyle: EditingStyle = .none

    /// - Parameters:
    ///   - title: The header title
    ///   - style: The UI style.
    public init(title: String, editingStyle: EditingStyle = .none, style: ListSectionHeaderStyle) {
        self.title = title
        self.editingStyle = editingStyle
        self.style = style
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(editingStyle)
    }
    
    public static func == (lhs: ListSectionHeader, rhs: ListSectionHeader) -> Bool {
        lhs.title == rhs.title && lhs.editingStyle == rhs.editingStyle
    }
}

/// A list section footer.
public struct ListSectionFooter: Hashable {

    /// The footer title.
    public var title: String

    /// The footer style.
    public var style: ListSectionFooterStyle

    /// - Parameters:
    ///   - title: The footer title
    ///   - style: The UI style.
    public init(title: String, style: ListSectionFooterStyle) {
        self.title = title
        self.style = style
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    public static func == (lhs: ListSectionFooter, rhs: ListSectionFooter) -> Bool {
        lhs.title == rhs.title
    }
}
