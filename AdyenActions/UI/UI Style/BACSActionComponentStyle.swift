//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Contains the styling customization options for the BACS Action component.
public struct BACSActionComponentStyle {
    
    /// The image style.
    public var image = ImageStyle(borderColor: nil,
                                  borderWidth: 0,
                                  cornerRadius: 0,
                                  clipsToBounds: false,
                                  contentMode: .center)
    
    /// The main button style.
    public var mainButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline),
                         color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )
    
    /// The message label style.
    public var messageLabel = TextStyle(font: .preferredFont(forTextStyle: .callout),
                                        color: UIColor.Adyen.componentLabel)
    
    /// Initializes the BACS action component style with the default style.
    public init() {}
}
