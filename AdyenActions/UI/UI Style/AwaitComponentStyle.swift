//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

/// Contains the styling customization options for the await component.
package struct AwaitComponentStyle: ViewStyle {

    /// The image style.
    package var image = ImageStyle(
        borderColor: nil,
        borderWidth: 0,
        cornerRadius: 0,
        clipsToBounds: false,
        contentMode: .center
    )
    
    /// The style of message label.
    package var message = TextStyle(
        font: .preferredFont(forTextStyle: .callout),
        color: UIColor.Adyen.componentLabel
    )
    
    /// The style of the spinner title label.
    package var spinnerTitle = TextStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.componentLoadingMessageColor,
        textAlignment: .left
    )
    
    package var backgroundColor = UIColor.Adyen.componentBackground

    /// Initializes the await component style with the default style.
    package init() {}
}
