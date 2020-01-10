//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Indicates any image UI style.
public struct ImageStyle: ViewStyle {
    
    /// Indicates the image border color.
    public var borderColor: UIColor?
    
    /// Indicates the image border width.
    public var borderWidth: CGFloat
    
    /// Indicates the corner radius of the image.
    public var cornerRadius: CGFloat
    
    /// Indicates whether to clip to the image bounds or not.
    public var clipsToBounds: Bool
    
    /// Indicates the image content mode.
    public var contentMode: UIView.ContentMode
    
    /// :nodoc:
    public var backgroundColor: UIColor = .componentBackground
    
    /// Initializes the image style
    ///
    /// - Parameter borderColor: The image border color.
    /// - Parameter borderWidth: The image border width.
    /// - Parameter cornerRadius: The image corner radius.
    /// - Parameter clipsToBounds: whether to clip the image to its bounds.
    /// - Parameter contentMode: The image content mode.
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
