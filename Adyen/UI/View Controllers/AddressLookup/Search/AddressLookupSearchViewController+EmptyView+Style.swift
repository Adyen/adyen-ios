//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension AddressLookupSearchViewController.EmptyView {
    
    internal struct Style: ViewStyle {
        
        internal var title: TextStyle = .init(
            font: .preferredFont(forTextStyle: .headline),
            color: .Adyen.componentLabel
        )
        internal var subtitle: TextStyle = .init(
            font: .preferredFont(forTextStyle: .subheadline),
            color: .Adyen.componentSecondaryLabel
        )
        internal var backgroundColor: UIColor = .clear
    }
}
