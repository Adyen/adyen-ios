//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal struct DropInAnalyticsConfiguration: AnalyticsStringDictionaryConvertible {
    
    private let skipPaymentMethodList: Bool
    
    private let openFirstStoredPaymentMethod: Bool
    
    internal init(configuration: DropInComponent.Configuration) {
        self.skipPaymentMethodList = configuration.allowsSkippingPaymentList
        self.openFirstStoredPaymentMethod = configuration.allowPreselectedPaymentView
    }
}
