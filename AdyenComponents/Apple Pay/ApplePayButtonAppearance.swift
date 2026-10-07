//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

/// The appearance of the Apple Pay button.
public struct ApplePayButtonAppearance {

    internal let buttonType: PKPaymentButtonType

    internal let buttonStyle: PKPaymentButtonStyle

    internal let cornerRadius: CGFloat?

    /// Creates an Apple Pay button appearance.
    /// - Parameters:
    ///   - buttonType: The type of the Apple Pay button, which determines its label. Defaults to `.plain`.
    ///   - buttonStyle: The style of the Apple Pay button.
    ///     Defaults to `.automatic`, which follows the system's light or dark appearance.
    ///   - cornerRadius: The corner radius of the Apple Pay button.
    ///     Defaults to `nil`, which keeps the system's default corner radius for the Apple Pay button.
    public init(
        buttonType: PKPaymentButtonType = .plain,
        buttonStyle: PKPaymentButtonStyle = .automatic,
        cornerRadius: CGFloat? = nil
    ) {
        self.buttonType = buttonType
        self.buttonStyle = buttonStyle
        self.cornerRadius = cornerRadius
    }
}
