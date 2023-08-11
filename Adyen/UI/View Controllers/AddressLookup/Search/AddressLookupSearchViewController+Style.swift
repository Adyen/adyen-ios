//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The style of the search screen for address lookup
public struct AddressLookupSearchStyle: ViewStyle {
    
    public var backgroundColor: UIColor = .Adyen.componentBackground
    
    public var manualEntryListItem: ListItemStyle = {
        var listItemStyle = ListItemStyle()
        listItemStyle.title.color = .Adyen.defaultBlue
        return listItemStyle
    }()
    
    public var emptyView: EmptyStateViewStyle = .init()
}
