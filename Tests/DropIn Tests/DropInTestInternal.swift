//
//  DropInTestInternal.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 25/08/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import AdyenDropIn
import XCTest

class DropInInternalTests: XCTestCase {

    func testFinaliseIfNeededSelectedComponent() throws {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethodsWithSingleInstant.data(using: .utf8)!)
        let sut = DropInComponent(paymentMethods: paymentMethods,
                                  context: Dummy.context,
                                  configuration: config)

        try presentOnRoot(sut.viewController, animated: true)
        
        let waitExpectation = expectation(description: "Expect Drop-In to finalize")

        let topVC = try waitForViewController(ofType: ListViewController.self, toBecomeChildOf: sut.viewController, timeout: 1)
        topVC.tableView(topVC.tableView, didSelectRowAt: .init(item: 0, section: 0))
        
        let cell = try XCTUnwrap(topVC.tableView.cellForRow(at: .init(item: 0, section: 0)) as? ListCell)
        XCTAssertTrue(cell.showsActivityIndicator)

        wait(for: .aMoment)

        sut.finalizeIfNeeded(with: true) {
            XCTAssertFalse(cell.showsActivityIndicator)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
