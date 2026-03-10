//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation

internal struct PaymentMethodListHeaderViewModel {
    internal let amount: String
    internal let subtitle: String
    internal let showApplePayButton: Bool
    internal let onApplePayTap: (() -> Void)?
    internal let theme: AdyenTheme
}
