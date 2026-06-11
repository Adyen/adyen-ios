//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

/// Contains the styling customization options for the QR code component.
package struct QRCodeComponentStyle: ViewStyle {
    
    /// The copy button style.
    package var copyCodeButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// The save as image button style.
    package var saveAsImageButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )
    
    /// The instruction label style.
    package var instructionLabel = TextStyle(font: .preferredFont(forTextStyle: .subheadline), color: UIColor.Adyen.componentLabel)
    
    /// The amount to pay label style.
    package var amountToPayLabel = TextStyle(
        font: .preferredFont(forTextStyle: .callout).adyen.font(with: .bold),
        color: UIColor.Adyen.componentLabel
    )

    /// The progress view style.
    package var progressView = ProgressViewStyle(
        progressTintColor: UIColor.Adyen.defaultBlue,
        trackTintColor: UIColor.Adyen.lightGray
    )
    
    /// The expiration label style.
    package var expirationLabel = TextStyle(font: .preferredFont(forTextStyle: .footnote), color: UIColor.Adyen.componentSecondaryLabel)
    
    /// The corner rounding for the logo
    package var logoCornerRounding: CornerRounding = .fixed(5)
        
    package var backgroundColor = UIColor.Adyen.componentBackground
    
    /// Initializes the QR code component style with the default style
    package init() {}
}
