//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// `CheckoutTheme` represents theme of the SDK required for dropIn and components UI.
public protocol CheckoutTheme {
    var checkoutLabelStyle: CheckoutLabelStyle { get set }
    var checkoutButtonStyles: CheckoutButtonStyles { get set }
    var checkoutTextFieldStyle: CheckoutTextFieldStyle { get set }
    
    // methods to produce a new theme with updated styles
    func withLabelStyle(_ style: CheckoutLabelStyle) -> CheckoutTheme
    func withButtonStyle(_ style: CheckoutButtonStyles) -> CheckoutTheme
    func withTextFieldStyle(_ style: CheckoutTextFieldStyle) -> CheckoutTheme
}

public protocol CheckoutLabelStyle {}
public protocol CheckoutButtonStyles {}
public protocol CheckoutTextFieldStyle {}
