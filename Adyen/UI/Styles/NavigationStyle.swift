//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The style of "Cancel" button.
public enum CancelButtonStyle {

    /// Default system style. Cross icon for iOS 13, system button "Cancel" for prior versions.
    case system

    /// System button "Cancel".
    case legacy

    /// Custom button with image.
    case custom(UIImage)
}

/// Modes for toolbar layout.
public enum ToolbarMode {

    /// Cancel button visually left aligned.
    case leftCancel

    /// Cancel button visually right aligned.
    case rightCancel

    /// Cancel button left aligned for RTL locales and right aligned for LTR.
    case natural

}

/// Indicates the navigation level style.
public struct NavigationStyle: TintableStyle {
    
    /// Indicates the navigation bar background color.
    public var backgroundColor = UIColor.Adyen.componentBackground
    
    /// The color of the thin line at the bottom of the navigation bar.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor?
    
    /// Indicates the navigation bar tint color.
    public var tintColor: UIColor?
    
    /// Indicates the corner radius of navigation bar top corners.
    public var cornerRadius: CGFloat = 10
    
    /// Indicates the bar title text style.
    public var barTitle = TextStyle(font: UIFont.AdyenCore.barTitle,
                                    color: UIColor.Adyen.componentLabel,
                                    textAlignment: .natural)

    /// The style of cancelButton. This property is not applicable to SFViewController in redirect component.
    public var cancelButton = CancelButtonStyle.system

    /// The mode for toolbar layout. Defines positions cancel button.
    public var toolbarMode = ToolbarMode.natural
    
    /// Initializes the navigation style.
    public init() {}
    
}
