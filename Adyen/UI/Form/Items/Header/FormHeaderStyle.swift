//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for form header.
public struct FormHeaderStyle: ViewStyle {
    /// The title style.
    public var title = TextStyle(font: UIFont.AdyenCore.largeTitle,
                                 color: UIColor.AdyenCore.componentLabel,
                                 textAlignment: .center)

    /// :nodoc:
    public var backgroundColor: UIColor = .clear

    /// Initializes the form header style
    ///
    /// - Parameter title: The title style.
    public init(title: TextStyle) {
        self.title = title
    }

    /// Initializes the form header style with the default style.
    public init() {}
}
