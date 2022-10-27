//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Delegate for observing user's activity on `CardComponent`.
public protocol CardComponentDelegate: AnyObject {

    /// Called when shopper enters PAN in `CardComponent`.
    /// - Parameter value: Up to 6 first digits in entered PAN.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeBIN(_ value: String, component: CardComponent)

    /// Called when `CardComponent` detected card type(s) in entered PAN.
    /// - Parameter value: Array of card types matching entered value. Null - if no data entered.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent)

    /// Called when shopper submits a card in `CardComponent`.
    /// - Parameter lastFour: Last 4 digits of card.
    /// - Parameter component: The `CardComponent` instance.
    func didSubmit(lastFour value: String, component: CardComponent)
}

extension CardComponentDelegate {

    /// :nodoc:
    public func didSubmit(lastFour value: String, component: CardComponent) {}

}
