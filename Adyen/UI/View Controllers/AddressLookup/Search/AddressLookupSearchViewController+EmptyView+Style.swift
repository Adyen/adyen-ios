//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct AddressLookupSearchEmptyStyle: ViewStyle {
    
    public var title: TextStyle = .init(
        font: .preferredFont(forTextStyle: .headline),
        color: .Adyen.componentLabel
    )
    public var subtitle: TextStyle = .init(
        font: .preferredFont(forTextStyle: .subheadline),
        color: .Adyen.componentSecondaryLabel
    )
    public var backgroundColor: UIColor = .Adyen.componentBackground
}
