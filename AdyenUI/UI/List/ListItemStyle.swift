//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for an item in a list.
package struct ListItemStyle: ViewStyle {

    /// The title style.
    package var title = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )
    
    /// The subtitle style.
    package var subtitle = TextStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .natural
    )

    /// The trailing title style.
    package var trailingText = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )
    
    /// The image style.
    package var image = ImageStyle(
        borderColor: UIColor.Adyen.componentSeparator,
        borderWidth: 1.0 / UIScreen.main.nativeScale,
        cornerRadius: 4.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
    
    package var backgroundColor = UIColor.Adyen.componentBackground

    /// Background color when highlighted (tapped).
    package var highlightedBackgroundColor: UIColor?

    /// Initializes the list item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter subtitle: The subtitle style.
    /// - Parameter image: The image style.
    package init(title: TextStyle, subtitle: TextStyle, image: ImageStyle) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    /// Initializes the list item style with the default style.
    package init() {}

}

extension ListItemStyle: Equatable {
    
    package static func == (lhs: ListItemStyle, rhs: ListItemStyle) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.image == rhs.image &&
            lhs.backgroundColor.cgColor == rhs.backgroundColor.cgColor
    }
    
}
