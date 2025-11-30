//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The style of the screen that performs an address lookup
package struct AddressLookupStyle: ViewStyle {
    
    package var backgroundColor: UIColor = .Adyen.componentBackground
    package var search: AddressLookupSearchStyle = .init()
    package var form: FormComponentStyle = .init()
    
    /// Initializes the address lookup style.
    ///
    /// - Parameter search: The address lookup search style
    /// - Parameter form: The form style
    package init(
        search: AddressLookupSearchStyle = .init(),
        form: FormComponentStyle = .init()
    ) {
        self.search = search
        self.form = form
    }
}
