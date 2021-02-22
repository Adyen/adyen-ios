//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Contains the styling customization options for the voucher component.
public struct VoucherComponentStyle: ViewStyle {

    /// The main button style.
    public var mainButton = ButtonStyle(title: TextStyle(font: .preferredFont(forTextStyle: .headline),
                                                         color: .white),
                                        cornerRadius: 8,
                                        background: UIColor.Adyen.defaultBlue)

    /// The secondary button style.
    public var secondaryButton = ButtonStyle(title: TextStyle(font: .preferredFont(forTextStyle: .headline),
                                                              color: UIColor.Adyen.defaultBlue),
                                             cornerRadius: 0,
                                             background: UIColor.Adyen.componentBackground)

    /// :nodoc:
    public var backgroundColor = UIColor.Adyen.componentBackground

    /// Initializes the voucher component style with the default style.
    public init() {}
}
