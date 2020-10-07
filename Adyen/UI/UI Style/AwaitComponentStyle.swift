//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for the await component.
public struct AwaitComponentStyle: ViewStyle {
    
    /// The image style.
    public var image = ImageStyle(borderColor: nil,
                                  borderWidth: 0,
                                  cornerRadius: 0,
                                  clipsToBounds: false,
                                  contentMode: .center)
    
    /// The style of message label.
    public var message = TextStyle(font: .preferredFont(forTextStyle: .callout),
                                   color: UIColor.AdyenCore.componentLabel)
    
    /// The style of the spinner title label.
    public var spinnerTitle = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                        color: UIColor.AdyenCore.componentLoadingMessageColor,
                                        textAlignment: .left)
    
    /// :nodoc:
    public var backgroundColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the await component style with the default style.
    public init() {}
}
