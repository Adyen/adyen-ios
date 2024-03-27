//
// Copyright © 2023 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class IssuerListComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: IssuerListPaymentMethod!
    private var sut: IssuerListComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context

        paymentMethod = try! AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testSelection() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        
        let searchViewController = sut.viewController as! SearchViewController
        let listViewController = searchViewController.resultsListViewController
        let expectedIssuer = paymentMethod.issuers[0]

        let expectation = expectation(description: "Call didSubmit")
        let mockDelegate = PaymentComponentDelegateMock()
        mockDelegate.onDidSubmit = { paymentData, paymentComponent in
            XCTAssertEqual(paymentData.amount, Dummy.payment.amount)
            
            XCTAssertTrue(paymentData.paymentMethod is IssuerListDetails)
            let details = paymentData.paymentMethod as! IssuerListDetails
            XCTAssertEqual(details.issuer, expectedIssuer.identifier)
            
            XCTAssertEqual(analyticsProviderMock.infoCount, 1)

            expectation.fulfill()
        }
        
        setupRootViewController(searchViewController)

        sut.delegate = mockDelegate
        listViewController.tableView(listViewController.tableView, didSelectRowAt: .init(item: 0, section: 0))

        waitForExpectations(timeout: 10)
    }
    
    func test_componentSendsInfo_onSearchInput_With_Throttling() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        
        let searchViewController = sut.viewController as! SearchViewController
        let listViewController = searchViewController.resultsListViewController
        
        setupRootViewController(searchViewController)
        
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "3")
        XCTAssertFalse(listViewController.view.isHidden)
        XCTAssertEqual(analyticsProviderMock.infoCount, 1)
        
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "34")
        // should not change before throttle delay passes
        XCTAssertEqual(analyticsProviderMock.infoCount, 1)
        wait(for: .seconds(1))
        
        // should update after throttle delay
        XCTAssertTrue(listViewController.view.isHidden)
        XCTAssertEqual(analyticsProviderMock.infoCount, 2)
    }

    func test_ViewDidLoad_ShouldSend_InitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let mockViewController = UIViewController()

        // When
        sut.viewDidLoad(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infoCount, 1)
    }
}
