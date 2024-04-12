//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

final class DummyTest: XCTestCase {
    func test() {
        let sut = DummyAnalyticsProvider()
        let error = AnalyticsEventError(component: "test",
                                        type: AnalyticsEventError.ErrorType.generic)
        sut.add(error: error)
    }
}
