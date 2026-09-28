//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum StorePaymentMethodPolicy {

    package static func shouldShowConsent(configuredVisible: Bool, amount: Amount?) -> Bool {
        configuredVisible && amount?.value != 0
    }

}
