//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for any progress views
package struct ProgressViewStyle: ViewStyle {

    /// The color shown for the portion of the progress bar that is filled
    package let progressTintColor: UIColor

    /// The color shown for the portion of the progress bar that is not filled.
    package let trackTintColor: UIColor

    package var backgroundColor = UIColor.clear

    /// Initializes the progress view style
    ///
    /// - Parameters:
    ///   - progressTintColor: The color shown for the portion of the progress bar that is filled
    ///   - trackTintColor: The color shown for the portion of the progress bar that is not filled.
    package init(progressTintColor: UIColor, trackTintColor: UIColor) {
        self.progressTintColor = progressTintColor
        self.trackTintColor = trackTintColor
    }
}
