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
        let sut = IssuerListComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let listViewController = sut.viewController as? ListViewController
        XCTAssertNotNil(listViewController)
        wait(for: .milliseconds(50))
        
        func getCell() -> ListCell {
            listViewController!.tableView.visibleCells[0] as! ListCell
        }
        let item = listViewController!.sections[0].items[0]
        XCTAssertFalse(getCell().showsActivityIndicator)
        listViewController?.startLoading(for: item)
        wait(for: .milliseconds(20))
        XCTAssertTrue(getCell().showsActivityIndicator)
        sut.stopLoadingIfNeeded()
        wait(for: .milliseconds(20))
        XCTAssertFalse(getCell().showsActivityIndicator)
    }

}
