//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import AdyenDropIn
import XCTest

class DropInInternalTests: XCTestCase {

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testFinaliseIfNeededSelectedComponent() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        presentOnRoot(sut.viewController)

        let waitExpectation = expectation(description: "Expect Drop-In to finalize")

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController)
        topVC.tableView(topVC.tableView, didSelectRowAt: .init(item: 0, section: 0))
        
        let cell = try XCTUnwrap(topVC.tableView.cellForRow(at: .init(item: 0, section: 0)) as? ListCell)
        XCTAssertTrue(cell.showsActivityIndicator)

        sut.finalizeIfNeeded(with: true) {
            XCTAssertFalse(cell.showsActivityIndicator)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
