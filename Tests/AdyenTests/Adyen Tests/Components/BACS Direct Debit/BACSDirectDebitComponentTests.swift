//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class BACSDirectDebitComponentTests: XCTestCase {

    var sut: BACSDirectDebitComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let paymentMethod = BACSDirectDebitPaymentMethod(type: "directdebit_GB",
                                                         name: "BACS Direct Debit")
        let apiContext = Dummy.context
        sut = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                       apiContext: apiContext)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testInitShouldSetViewControllerPresenter() throws {
        // Then
        let viewController = try XCTUnwrap(sut.viewController as? BACSDirectDebitInputFormViewController)
        XCTAssertNotNil(viewController.presenter)
    }
}
