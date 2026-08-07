//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct StoredPaymentMethodManagementItem {

    internal let paymentMethod: any StoredPaymentMethod
    internal let title: String
    internal let subtitle: String?
    internal let logoURL: URL
    internal let accessibilityLabel: String?
}
