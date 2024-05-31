//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for an item in a selectable form.
public struct SelectableFormItemStyle: ViewStyle {

    /// The title style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .body),
                                 color: UIColor.Adyen.componentLabel,
                                 textAlignment: .natural)

    /// The image style.
    public var imageStyle = ImageStyle(borderColor: UIColor.Adyen.componentSeparator,
                                       borderWidth: 1.0 / UIScreen.main.nativeScale,
                                       cornerRadius: 4.0,
                                       clipsToBounds: true,
                                       contentMode: .scaleAspectFit)

    public var backgroundColor = UIColor.Adyen.componentBackground

    /// Initializes the selectableForm item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter imageStyle: The image style.
    /// - Parameter checkmarkImageStyle: The checkmarkImage style.
    public init(title: TextStyle,
                subtitle: TextStyle,
                imageStyle: ImageStyle,
                checkmarkImageStyle: ImageStyle? = nil) {
        self.title = title
        self.imageStyle = imageStyle
    }

    /// Initializes the list item style with the default style.
    public init() {}

}

extension SelectableFormItemStyle: Equatable {

    public static func == (lhs: SelectableFormItemStyle, rhs: SelectableFormItemStyle) -> Bool {
        lhs.title == rhs.title &&
            lhs.imageStyle == rhs.imageStyle &&
            lhs.backgroundColor.cgColor == rhs.backgroundColor.cgColor
    }

}
