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
    public let header: ListSectionHeader?

    /// The items inside the section.
    public let items: [ListItem]

    /// The footer title of the section.
    public let footer: ListSectionFooter?
    
    /// Initializes the picker section.
    ///
    /// - Parameters:
    ///   - header: The section header.
    ///   - items: The items inside the section.
    ///   - footer: The section footer.
    public init(header: ListSectionHeader? = nil, items: [ListItem], footer: ListSectionFooter? = nil) {
        self.header = header
        self.items = items
        self.footer = footer
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
