//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a list section header.
public struct ListSectionHeaderStyle: ViewStyle {
    
    /// The title style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .subheadline),
                                 color: UIColor.Adyen.componentSecondaryLabel,
                                 textAlignment: .natural)
    
    /// The trailing button style.
    public var trailingButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .body),
                         color: UIColor.Adyen.defaultBlue),
        cornerRounding: .none,
        background: UIColor.clear
    )
    
    /// :nodoc:
    public var backgroundColor = UIColor.Adyen.componentBackground
    
    /// Initializes the list header style.
    ///
    /// - Parameter title: The title style.
    public init(title: TextStyle) {
        self.title = title
    }
    
    /// Initializes the list header style with the default style.
    public init() {}
    
}
