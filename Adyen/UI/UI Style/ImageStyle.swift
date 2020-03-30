//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for any images.
public struct ImageStyle: ViewStyle {
    
    /// The color of the image's border.
    public var borderColor: UIColor?
    
    /// The width of the image's border.
    public var borderWidth: CGFloat
    
    /// The image's corner radius.
    public var cornerRadius: CGFloat
    
    /// A boolean value that determines whether the image is confined to the bounds of the view.
    public var clipsToBounds: Bool
    
    /// A flag used to determine how to lay out the image in its bounds.
    public var contentMode: UIView.ContentMode
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
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
        self.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBounds
        self.contentMode = contentMode
    }
    
}
