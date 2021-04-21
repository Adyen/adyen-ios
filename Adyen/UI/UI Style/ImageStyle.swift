//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for any images.
public struct ImageStyle: TintableStyle {
    
    /// The color of the image's border.
    public var borderColor: UIColor?
    
    /// The width of the image's border.
    public var borderWidth: CGFloat
    
    /// The corners style of the image.
    public var cornerRounding: CornerRounding
    
    /// A boolean value that determines whether the image is confined to the bounds of the view.
    public var clipsToBounds: Bool
    
    /// A flag used to determine how to lay out the image in its bounds.
    public var contentMode: UIView.ContentMode
    
    /// :nodoc:
    public var backgroundColor = UIColor.Adyen.componentBackground
    
    /// The tint color of the icon.
    public var tintColor: UIColor?
    
    /// Initializes the image style.
    ///
    /// - Parameter borderColor: The color of the image's border.
    /// - Parameter borderWidth: The width of the image's border.
    /// - Parameter cornerRadius: The image's corner radius.
    /// - Parameter clipsToBounds: A boolean value that determines whether the image is confined to the bounds of the view.
    /// - Parameter contentMode: A flag used to determine how to lay out the image in its bounds.
    public init(borderColor: UIColor?,
                borderWidth: CGFloat,
                cornerRadius: CGFloat,
                clipsToBounds: Bool,
                contentMode: UIView.ContentMode) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRounding = .fixed(cornerRadius)
        self.clipsToBounds = clipsToBounds
        self.contentMode = contentMode
    }
    
    /// Initializes the image style.
    ///
    /// - Parameter borderColor: The color of the image's border.
    /// - Parameter borderWidth: The width of the image's border.
    /// - Parameter cornerRounding: The image's corner style.
    /// - Parameter clipsToBounds: A boolean value that determines whether the image is confined to the bounds of the view.
    /// - Parameter contentMode: A flag used to determine how to lay out the image in its bounds.
    public init(borderColor: UIColor?,
                borderWidth: CGFloat,
                cornerRounding: CornerRounding,
                clipsToBounds: Bool,
                contentMode: UIView.ContentMode) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRounding = cornerRounding
        self.clipsToBounds = clipsToBounds
        self.contentMode = contentMode
    }
    
}

extension ImageStyle: Equatable {
    
    public static func == (lhs: ImageStyle, rhs: ImageStyle) -> Bool {
        lhs.borderColor?.cgColor == rhs.borderColor?.cgColor &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.cornerRounding == rhs.cornerRounding &&
            lhs.contentMode == rhs.contentMode &&
            lhs.tintColor == rhs.tintColor
    }
    
}
