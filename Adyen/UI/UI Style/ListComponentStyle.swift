//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for any list-based component.
public struct ListComponentStyle: ViewStyle {
    
    /// The style of any of the items in the list.
    public var listItem: ListItemStyle = ListItemStyle()
    
    /// The style of any of the section headers in the list.
    public var sectionHeader: ListSectionHeaderStyle = ListSectionHeaderStyle()
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the list component style.
    ///
    /// - Parameter listItem: The style of any of the items in the list.
    /// - Parameter sectionHeader: The style of any of the section headers in the list.
    public init(listItem: ListItemStyle,
                sectionHeader: ListSectionHeaderStyle) {
        self.listItem = listItem
        self.sectionHeader = sectionHeader
    }
    
    /// Initializes the list component style with the default style.
    public init() {}
}
