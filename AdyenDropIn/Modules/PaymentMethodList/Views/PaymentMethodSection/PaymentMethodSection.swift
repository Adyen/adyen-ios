//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct PaymentMethodSection: Identifiable {

    internal let id = UUID()
    internal let headerTitle: String?
    internal let items: [PaymentMethodItem]
    
    internal init(
        headerTitle: String? = nil,
        items: [PaymentMethodItem]
    ) {
        self.headerTitle = headerTitle
        self.items = items
    }
}
