//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for an item in a FormCoBadged card Item.

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
        color: UIColor.Adyen.componentLabel,
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
    internal init(
        title: TextStyle,
        subtitle: TextStyle
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}

extension FormCoBadgedCardItemStyle: Equatable {

    internal static func == (lhs: FormCoBadgedCardItemStyle, rhs: FormCoBadgedCardItemStyle) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.backgroundColor.cgColor == rhs.backgroundColor.cgColor
    }
}
