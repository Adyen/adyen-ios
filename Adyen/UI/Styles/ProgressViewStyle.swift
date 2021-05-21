//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for any progress views
public struct ProgressViewStyle: ViewStyle {
    
    /// The color shown for the portion of the progress bar that is filled
    public let progressTintColor: UIColor
    
    /// The color shown for the portion of the progress bar that is not filled.
    public let trackTintColor: UIColor
    
    /// :nodoc:
    public var backgroundColor = UIColor.clear
    
    /// Initializes the progress view style
    ///
    /// - Parameters:
    ///   - progressTintColor: The color shown for the portion of the progress bar that is filled
    ///   - trackTintColor: The color shown for the portion of the progress bar that is not filled.
    public init(progressTintColor: UIColor, trackTintColor: UIColor) {
        self.progressTintColor = progressTintColor
        self.trackTintColor = trackTintColor
    }
}
