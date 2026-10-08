//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

internal struct PaymentMethodListHeaderViewModel {
    internal let title: String
    internal let subtitle: String
    /// The Apple Pay component's button, or `nil` when Apple Pay isn't available.
    internal let applePayView: UIView?
    internal let theme: CheckoutTheme
}
