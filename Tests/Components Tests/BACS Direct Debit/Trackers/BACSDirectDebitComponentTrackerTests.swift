//

@testable import Adyen
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

    func testSendTelemetryEventShouldCallAnalyticsProviderSendTelemetryEvent() throws {
        // When
        sut.sendInitialAnalytics()

        // Then
        XCTAssertEqual(analyticsProvider.initialTelemetryEventCallsCount, 1)
    }
}
