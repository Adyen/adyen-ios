//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct AddressLookupStyle: ViewStyle {
    
    public var backgroundColor: UIColor = .Adyen.componentBackground
    public var search: AddressLookupSearchStyle = .init()
    public var form: FormComponentStyle = .init()
    
    public init() {}
}
