//
//  IssuerListComponentUITests.swift
//  AdyenUIHostUITests
//
//  Created by Mohamed Eldoheiri on 10/01/2023.
//  Copyright © 2023 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import SnapshotTesting
import XCTest

final class IssuerListComponentUITests: XCTestCase {

    func testStartStopLoading() throws {
        
        let context = Dummy.context
        let paymentMethod = try Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        
        let sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        let listViewController = searchViewController.resultsListViewController
        
        setupRootViewController(sut.viewController)
        
        let items = listViewController.sections[0].items
        
        let index = 0
        let item = items[index]
        var cell = try XCTUnwrap(getCell(for: item, tableView: listViewController.tableView))
        XCTAssertFalse(cell.showsActivityIndicator)
        assertViewControllerImage(matching: sut.viewController, named: "initial_state")
    
        // start loading
        listViewController.startLoading(for: item)
        cell = try XCTUnwrap(getCell(for: item, tableView: listViewController.tableView))
        XCTAssertTrue(cell.showsActivityIndicator)
        assertViewControllerImage(matching: sut.viewController, named: "loading_first_cell")
        
        // stop loading
        sut.stopLoadingIfNeeded()
        cell = try XCTUnwrap(getCell(for: item, tableView: listViewController.tableView))
        XCTAssertFalse(cell.showsActivityIndicator)
        assertViewControllerImage(matching: sut.viewController, named: "stopped_loading")
    }
    
    private func getCell(for item: ListItem, tableView: UITableView) -> ListCell? {
        for case let cell as ListCell in tableView.visibleCells where cell.item == item {
            return cell
        }
        
        return nil
    }

}
