//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension FormPickerSearchViewController.EmptyView {
    
    /// Initializes the `Style` of the ``FormPickerSearchViewController.EmptyView``
    internal struct Style: ViewStyle {
        
        internal var title: TextStyle
        internal var subtitle: TextStyle
        internal var backgroundColor: UIColor
        
        internal init(
            title: TextStyle = .init(
                font: .preferredFont(forTextStyle: .headline),
                color: .Adyen.componentLabel
            ),
            subtitle: TextStyle = .init(
                font: .preferredFont(forTextStyle: .subheadline),
                color: .Adyen.componentSecondaryLabel
            ),
            backgroundColor: UIColor = .clear
        ) {
            self.title = title
            self.subtitle = subtitle
            self.backgroundColor = backgroundColor
        }
    }
}
