//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import SnapshotTesting
import XCTest

final class IssuerListComponentUITests: XCTestCase {

    private var context: AdyenContext { Dummy.context }
    private var paymentMethod: IssuerListPaymentMethod { try! AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod }

    func testStartStopLoading() throws {
        let sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        let listViewController = searchViewController.resultsListViewController
        
        setupRootViewController(sut.viewController)
        
        let item = try XCTUnwrap(listViewController.sections.first?.items.first)
        
        var cell = try XCTUnwrap(Self.getCell(for: item, tableView: listViewController.tableView))
        XCTAssertFalse(cell.showsActivityIndicator)
        XCTAssertTrue(listViewController.tableView.isUserInteractionEnabled)
        assertViewControllerImage(matching: sut.viewController, named: "initial_state")
    
        // start loading
        item.startLoading()
        cell = try XCTUnwrap(Self.getCell(for: item, tableView: listViewController.tableView))
        XCTAssertTrue(cell.showsActivityIndicator)
        XCTAssertFalse(listViewController.tableView.isUserInteractionEnabled)
        assertViewControllerImage(matching: sut.viewController, named: "loading_first_cell")
        
        // stop loading
        sut.stopLoadingIfNeeded()
        cell = try XCTUnwrap(Self.getCell(for: item, tableView: listViewController.tableView))
        XCTAssertFalse(cell.showsActivityIndicator)
        XCTAssertTrue(listViewController.tableView.isUserInteractionEnabled)
        assertViewControllerImage(matching: sut.viewController, named: "stopped_loading")
        
        // start loading again
        item.startLoading()
        cell = try XCTUnwrap(Self.getCell(for: item, tableView: listViewController.tableView))
        XCTAssertFalse(listViewController.tableView.isUserInteractionEnabled)
        XCTAssertTrue(cell.showsActivityIndicator)
        
        // stop loading on item -> should stop loading on list
        item.stopLoading()
        cell = try XCTUnwrap(Self.getCell(for: item, tableView: listViewController.tableView))
        XCTAssertTrue(listViewController.tableView.isUserInteractionEnabled)
        XCTAssertFalse(cell.showsActivityIndicator)
        
    }
    
    private static func getCell(for item: ListItem, tableView: UITableView) -> ListCell? {
        tableView.visibleCells.first { cell in
            (cell as? ListCell).map { $0.item == item } ?? false
        } as? ListCell
    }
}
