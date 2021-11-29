//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit
import UIKit

///  Contains the styling options for Apple Pay components.
public struct ApplePayStyle {
    
    /// Style of the payment button. When nil, it's set to automatic based on Dark or Light Mode.
    public var paymentButtonStyle: PKPaymentButtonStyle?
    
    /// Type of the Apple Pay payment button. Default is `.plain`
    public var paymentButtonType: PKPaymentButtonType
    
    /// Corner radius for the payment button. iOS 12 or above. Defaults to 4 points.
    public var cornerRadius: CGFloat
    
    /// Stying for the label that contains the formatted amount text.
    public var hintLabelStyle: TextStyle
    
    /// Background color for the Apple Pay component.
    public var backgroundColor: UIColor

    /// Initializes an Apple Pay style instance with default values.
    public init() {
        paymentButtonType = .plain
        cornerRadius = 4
        backgroundColor = UIColor.Adyen.componentBackground
        hintLabelStyle = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                   color: UIColor.Adyen.componentSecondaryLabel)
    }
}
