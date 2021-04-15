//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Contains the styleing customization options for the QR code component.
public struct QRCodeComponentStyle: ViewStyle {
    
    /// The copy button style.
    public var copyButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )
    
    public var instructionLabel = TextStyle(font: .preferredFont(forTextStyle: .headline),
        color: .black)
        
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.Adyen.componentBackground
    
    /// Initializes the QR code component style with the default style
    public init() {}
}
