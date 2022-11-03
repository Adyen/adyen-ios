//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// To make Carthages work on CI
@_spi(AdyenInternal) @testable import Adyen

extension Dummy {

    internal static func context(with analyticsProvider: AnalyticsProviderProtocol) -> AdyenContext {
        AdyenContext(apiContext: apiContext,
                     payment: payment,
                     analyticsProvider: analyticsProvider)
    }

}
