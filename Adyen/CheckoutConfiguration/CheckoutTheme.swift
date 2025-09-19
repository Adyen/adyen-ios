//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// `CheckoutTheme` represents theme of the SDK required for dropIn and components UI.
package protocol CheckoutTheme: CheckoutColorScheme {
    var checkoutLabelStyle: CheckoutLabelStyle { get }
    var checkoutButtonStyles: CheckoutButtonStyles { get }
    
    // methods to produce a new theme with updated styles
    func label(_ style: CheckoutLabelStyle) -> CheckoutTheme
    func button(_ style: CheckoutButtonStyles) -> CheckoutTheme
}

public protocol CheckoutLabelStyle {}
public protocol CheckoutButtonStyles {}

package protocol CheckoutColorScheme {
    var background: UIColor { get }
}
