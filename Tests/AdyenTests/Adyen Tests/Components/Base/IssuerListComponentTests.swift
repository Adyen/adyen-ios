//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class IssuerListComponentTests: XCTestCase {

    func testStartStopLoading() {
        let paymentMethod = try! Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        let sut = IssuerListComponent(paymentMethod: paymentMethod)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let listViewController = sut.viewController as? ListViewController
        XCTAssertNotNil(listViewController)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let item = listViewController!.sections[0].items[0]
            let cell = listViewController!.tableView.visibleCells[0] as! ListCell
            XCTAssertFalse(cell.showsActivityIndicator)
            listViewController?.startLoading(for: item)
            XCTAssertTrue(cell.showsActivityIndicator)
            sut.stopLoadingIfNeeded()
            XCTAssertFalse(cell.showsActivityIndicator)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

}
