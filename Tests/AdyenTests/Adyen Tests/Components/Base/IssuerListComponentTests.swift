//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class IssuerListComponentTests: XCTestCase {

    func testStartStopLoading() {
        let paymentMethod = try! Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        let sut = IssuerListComponent(paymentMethod: paymentMethod, apiContext: Dummy.context)

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let listViewController = sut.viewController as? ListViewController
        XCTAssertNotNil(listViewController)
        
        wait(for: .milliseconds(300))
        
        let item = listViewController!.sections[0].items[0]
        let cell = listViewController!.tableView.visibleCells[0] as! ListCell
        XCTAssertFalse(cell.showsActivityIndicator)
        listViewController?.startLoading(for: item)
        XCTAssertTrue(cell.showsActivityIndicator)
        sut.stopLoadingIfNeeded()
        XCTAssertFalse(cell.showsActivityIndicator)
    }

}
