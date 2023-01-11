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

    private var context: AdyenContext!
    private var paymentMethod: IssuerListPaymentMethod!
    private var sut: IssuerListComponent!
    private var searchViewController: SearchViewController!
    private var listViewController: ListViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()

        initializeComponent()
    }
    
    private func initializeComponent() {
        context = Dummy.context
        paymentMethod = try! Coder.decode(issuerListDictionary) as IssuerListPaymentMethod
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        searchViewController = sut.viewController as? SearchViewController
        listViewController = searchViewController.childViewController as? ListViewController
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testStartStopLoading() {
        XCTAssertNotNil(listViewController)
        
        let items = listViewController!.sections[0].items
        let index = 0
        let item = items[index]
        var cell = listViewController!.tableView.visibleCells[index] as! ListCell
        XCTAssertFalse(cell.showsActivityIndicator)
        assertSnapshot(matching: sut.viewController, as: .image(on: .iPhone12), named: "initial_state")
    
        // start loading
        listViewController?.startLoading(for: item)
        cell = getCell(for: item, tableView: listViewController!.tableView)!
        XCTAssertTrue(cell.showsActivityIndicator)
        assertSnapshot(matching: sut.viewController, as: .image(on: .iPhone12), named: "loading_first_cell")
        
        // stop loading
        sut.stopLoadingIfNeeded()
        cell = getCell(for: item, tableView: listViewController!.tableView)!
        XCTAssertFalse(cell.showsActivityIndicator)
        assertSnapshot(matching: sut.viewController, as: .image(on: .iPhone12), named: "stopped_loading")
        
    }
    
    private func getCell(for item: ListItem, tableView: UITableView) -> ListCell? {
        for case let cell as ListCell in tableView.visibleCells where cell.item == item {
            return cell
        }
        
        return nil
    }

}
