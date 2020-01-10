//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates any list component UI style.
public protocol AnyListComponentStyle: ViewStyle {
    
    /// Indicates the list item UI style.
    var listItem: ListItem.Style { get set }
    
    /// Indicates the section header UI style.
    var sectionHeader: ListHeaderViewStyle { get set }
    
}

/// Indicates any list component UI style.
public struct ListComponentStyle: AnyListComponentStyle {
    
    /// Indicates the list item UI style.
    public var listItem: ListItem.Style = ListItem.Style()
    
    /// Indicates the section header UI style.
    public var sectionHeader: ListHeaderViewStyle = ListHeaderViewStyle()
    
    /// :nodoc:
    public var backgroundColor: UIColor = .componentBackground
    
    /// Initializes the list view controller style.
    ///
    /// - Parameter listItem: The individual list item UI style.
    /// - Parameter sectionHeader: The list section header UI style.
    public init(listItem: ListItem.Style,
                sectionHeader: ListHeaderViewStyle) {
        self.listItem = listItem
        self.sectionHeader = sectionHeader
    }
    
    /// Initializes the list view controller style with default style.
    public init() {}
}
