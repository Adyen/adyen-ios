//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

// Contains the styling customization options for an item in a FormCoBadged card Item.

internal struct FormCoBadgedCardItemStyle: ViewStyle {

    /// The title style.
    internal var title = TextStyle(
        font: .preferredFont(forTextStyle: .headline),
        color: .black,
        textAlignment: .natural
    )

    /// The subtitle style.
    internal var subtitle = TextStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .natural
    )

    /// The background color.
    internal var backgroundColor: UIColor {
        get { title.backgroundColor }
        set { title.backgroundColor = newValue }
    }

    /// Initializes the FormCoBadged card item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter subtitle: The subtitle style.
    /// - Parameter backgroundColor: The background color.
    internal init(
        title: TextStyle,
        subtitle: TextStyle,
        backgroundColor: UIColor = .clear
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
    }
}
