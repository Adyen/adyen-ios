//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// Delegate for observing user's activity on `CardComponent`.
public protocol CardComponentDelegate: AnyObject {

    /// Called with the first 6 or 8 digits typed by the shopper in the PAN field in `CardComponent`.
    ///
    /// - Parameter value: Up to 8 first digits in entered PAN.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeBIN(_ value: String, component: CardComponent)

    /// Called when `CardComponent` detected card type(s) in entered PAN.
    ///
    /// - Parameter value: Array of card types matching entered value. Null - if no data entered.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent)

    /// Called when shopper submits the `CardComponent` form.
    ///
    /// - Parameter lastFour: Last 4 digits of card.
    /// - Parameter finalBIN: The final Card BIN.
    /// - Parameter component: The `CardComponent` instance.
    func didSubmit(lastFour: String, finalBIN: String, component: CardComponent)
}

extension CardComponentDelegate {

    public func didSubmit(lastFour value: String, component: CardComponent) {}

}
