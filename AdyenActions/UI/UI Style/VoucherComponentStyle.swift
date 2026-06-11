//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

/// Contains the styling customization options for the voucher component.
package struct VoucherComponentStyle: ViewStyle {
    
    /// The amount label style.
    package var amountLabel = TextStyle(
        font: .preferredFont(forTextStyle: .largeTitle),
        color: UIColor.Adyen.componentLabel
    )
    
    /// The currency label style.
    package var currencyLabel = TextStyle(
        font: .preferredFont(forTextStyle: .headline),
        color: UIColor.Adyen.componentLabel
    )
    
    /// The edit button style.
    package var editButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRounding: .none,
        background: UIColor.clear
    )
    
    /// The done button style.
    package var doneButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRounding: .none,
        background: UIColor.clear
    )

    /// The main button style.
    package var mainButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: .white
        ),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// The secondary button style.
    package var secondaryButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRadius: 8,
        background: .clear
    )
    
    /// The secondary button copy code confirmation color
    package var codeConfirmationColor = UIColor.Adyen.green40

    package var backgroundColor = UIColor.Adyen.componentBackground

    /// Initializes the voucher component style with the default style.
    package init() {}
}
