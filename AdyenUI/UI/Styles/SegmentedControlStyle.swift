//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any segmented control.
package struct SegmentedControlStyle: TintableStyle {

    /// The textStyle used to customize the text
    package var textStyle: TextStyle

    /// The background color of segmented control.
    package var backgroundColor: UIColor

    /// The tintColor used to changes the selected segment tint color.
    package var tintColor: UIColor?

    /// Initializes the segmented control style.
    ///
    /// - Parameter textStyle: the style of the text
    /// - Parameter backgroundColor: The background color.
    /// -  Parameter tintColor: The background color of the selected segment.
    package init(
        textStyle: TextStyle,
        backgroundColor: UIColor = .clear,
        tintColor: UIColor = .white
    ) {
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
    }

}
