//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitComponentTrackerTests: XCTestCase {

    var apiContext: APIContext!
    var analyticsProvider: AnalyticsProviderMock!
    var sut: BACSDirectDebitComponentTracker!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let paymentMethod = BACSDirectDebitPaymentMethod(type: .bacsDirectDebit,
                                                         name: "BACS Direct Debit")

        apiContext = Dummy.apiContext
        analyticsProvider = AnalyticsProviderMock()
        let adyenContext = AdyenContext(apiContext: apiContext, payment: Dummy.payment, analyticsProvider: analyticsProvider)
        sut = BACSDirectDebitComponentTracker(paymentMethod: paymentMethod,
                                              context: adyenContext,
                                              isDropIn: false)
    }

    override func tearDownWithError() throws {
        apiContext = nil
        analyticsProvider = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testSendInitialEventShouldCallAnalyticsProviderSendInitialEvent() throws {
        // When
        sut.sendInitialAnalytics()

        // Then
        XCTAssertEqual(analyticsProvider.initialEventCallsCount, 1)
    }
    
    func testSendRenderEventShouldAddInfoCount() {
        sut.sendDidLoadEvent()
        
        XCTAssertEqual(analyticsProvider.infos.count, 1)
        let infoType = analyticsProvider.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }
}
