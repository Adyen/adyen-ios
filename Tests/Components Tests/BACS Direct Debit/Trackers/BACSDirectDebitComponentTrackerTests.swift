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
        sut = BACSDirectDebitComponentTracker(paymentMethod: paymentMethod,
                                              apiContext: apiContext,
                                              telemetryTracker: analyticsProvider,
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
        sut.sendTelemetryEvent()

        // Then
        XCTAssertEqual(analyticsProvider.sendTelemetryEventCallsCount, 1)
    }
}
