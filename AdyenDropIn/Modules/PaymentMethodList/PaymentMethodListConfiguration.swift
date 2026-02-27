//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Payment methods list related configurations.
public struct PaymentMethodListConfiguration {

    public init() { /* Empty initializer */ }

    /// Indicates whether to allow shoppers to disable/delete stored payment methods
    public var allowDisablingStoredPaymentMethods: Bool = false
}
