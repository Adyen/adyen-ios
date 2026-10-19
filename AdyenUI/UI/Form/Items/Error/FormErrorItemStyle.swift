//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for an error item in a form.
package struct FormErrorItemStyle: ViewStyle {

    /// The message style.
    package var message = TextStyle(
        font: .preferredFont(forTextStyle: .callout),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )

    /// The corners style of the text item.
    package var cornerRounding: CornerRounding = .fixed(6)

    package var backgroundColor = UIColor.Adyen.errorRed.withAlphaComponent(0.1)

    /// Initializes the form error item style.
    ///
    /// - Parameter message: The message style.
    package init(message: TextStyle) {
        self.message = message
    }

    /// Initializes the form error item style with the default style.
    package init() {}
}
