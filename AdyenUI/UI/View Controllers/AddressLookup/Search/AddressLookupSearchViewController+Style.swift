//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The style of the search screen for address lookup
package struct AddressLookupSearchStyle: ViewStyle {

    package var backgroundColor: UIColor = .Adyen.componentBackground

    package var manualEntryListItem: ListItemStyle = {
        var listItemStyle = ListItemStyle()
        listItemStyle.title.color = .Adyen.defaultBlue
        return listItemStyle
    }()
    
    package var emptyView: EmptyStateViewStyle = .init()

    package init() {}
}
