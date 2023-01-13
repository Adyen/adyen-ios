//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any segmented control.
public struct SegmentedControlStyle: TintableStyle {

    /// The textStyle used to customize the text
    public var textStyle: TextStyle

    /// The backgroundColor used to change the background color of segmented control.
    public var backgroundColor: UIColor

    /// The tintColor used to changes the selected segment tint color.
    public var tintColor: UIColor?

    /// Initializes the segmented control style.
    ///
    /// - Parameter textStyle: the style of the text
    /// - Parameter backgroundColor: The background color.
    /// -  Parameter selectedSegmentTintColor: The background color of selected segment.
    public init(textStyle: TextStyle,
                backgroundColor: UIColor = .clear,
                selectedSegmentTintColor: UIColor = .white) {
        self.textStyle = textStyle
        self.backgroundColor = backgroundColor
        self.tintColor = selectedSegmentTintColor
    }

}
