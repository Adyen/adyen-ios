//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a redirect component.
public struct RedirectComponentStyle {
    
    /// The preferred color to tint the background of the navigation bar and toolbar.
    public let preferredBarTintColor: UIColor?
    
    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    public let preferredControlTintColor: UIColor
    
    /// The modal presentation style of the redirect component.
    public let modalPresentationStyle: UIModalPresentationStyle
    
    /// Initializes the redirect component style.
    ///
    /// - Parameter preferredBarTintColor: The preferred color to tint the background of the navigation bar and toolbar.
    /// - Parameter preferredControlTintColor: The preferred color to tint the control buttons on the navigation bar and toolbar.
    /// - Parameter modalPresentationStyle: The modal presentation style of the redirect component.
    public init(preferredBarTintColor: UIColor? = nil,
                preferredControlTintColor: UIColor = .systemBlue,
                modalPresentationStyle: UIModalPresentationStyle = .formSheet) {
        self.preferredBarTintColor = preferredBarTintColor
        self.preferredControlTintColor = preferredControlTintColor
        self.modalPresentationStyle = modalPresentationStyle
    }
    
}
