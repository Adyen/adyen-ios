//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class PayToComponentUITests: XCTestCase {

    private lazy var paymentMethod: PayToPaymentMethod = .init(
        type: .payTo,
        name: "payto"
    )
    private var context: AdyenContext { Dummy.context }
    private var style: FormComponentStyle { FormComponentStyle() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    // TODO: Write tests when UI is complete
}
