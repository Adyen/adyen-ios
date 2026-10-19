//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a list section header.
package struct ListSectionHeaderStyle: ViewStyle {

    /// The title style.
    package var title = TextStyle(
        font: .preferredFont(forTextStyle: .subheadline),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .natural
    )
    
    /// The trailing button style.
    package var trailingButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .body),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRounding: .none,
        background: UIColor.clear
    )
    
    package var backgroundColor = UIColor.Adyen.componentBackground

    /// Initializes the list header style.
    ///
    /// - Parameter title: The title style.
    package init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the list header style with the default style.
    package init() {}
    
}
