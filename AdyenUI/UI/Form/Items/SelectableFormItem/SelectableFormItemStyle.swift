//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for an item in a selectable form.
@_spi(AdyenInternal)
public struct SelectableFormItemStyle: ViewStyle {

    /// The title style.
    public var title = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )

    /// The image style.
    public var imageStyle = ImageStyle(
        borderColor: UIColor.Adyen.componentSeparator,
        borderWidth: 1.0 / UIScreen.main.nativeScale,
        cornerRadius: 4.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )

    /// The background color.
    public var backgroundColor: UIColor {
        get { title.backgroundColor }
        set { title.backgroundColor = newValue }
    }

    /// The color for separator element.
    public var separatorColor: UIColor? = UIColor.Adyen.componentSeparator

    /// Initializes the selectableForm item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter separatorColor: The separator color.
    public init(
        title: TextStyle,
        separatorColor: UIColor? = nil
    ) {
        self.title = title
        self.separatorColor = separatorColor
    }
}

@_spi(AdyenInternal)
extension SelectableFormItemStyle: Equatable {

    public static func == (lhs: SelectableFormItemStyle, rhs: SelectableFormItemStyle) -> Bool {
        lhs.title == rhs.title &&
            lhs.imageStyle == rhs.imageStyle &&
            lhs.backgroundColor.cgColor == rhs.backgroundColor.cgColor
    }

}
