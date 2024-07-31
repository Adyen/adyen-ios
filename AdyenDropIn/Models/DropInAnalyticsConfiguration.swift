//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal struct DropInAnalyticsConfiguration: AnalyticsStringDictionaryConvertible {
    
    private let allowsSkippingPaymentList: Bool
    
    private let allowPreselectedPaymentView: Bool
}
