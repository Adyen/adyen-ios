//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

internal struct PaymentMethodListHeaderViewModel {

    internal enum ApplePayButtonState {
        case hidden
        case visible(onTap: () -> Void)
    }

    internal let amount: String
    internal let subtitle: String
    internal let applePayButtonState: ApplePayButtonState
    internal let theme: AdyenTheme
}
