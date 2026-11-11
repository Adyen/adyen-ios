//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class IssuerListComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: IssuerListPaymentMethod!
    private var sut: IssuerListComponent!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
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

    func test_selectingIssuer_shouldNotSubmit_andShouldMarkRowAsSelected() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: Dummy.context(analyticsProvider: analyticsProviderMock))
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        let listViewController = try presentList()

        // When
        selectRow(at: 0, in: listViewController)

        // Then
        XCTAssertFalse(delegateMock.didSubmitCalled)
        XCTAssertEqual(selectedRowIndices(in: listViewController), [0])
        XCTAssertEqual(analyticsProviderMock.infos.map(\.type), [.rendered, .selected])
    }

    func test_selectingAnotherIssuer_shouldMoveSelection() throws {
        // Given
        let listViewController = try presentList()
        selectRow(at: 0, in: listViewController)

        // When
        selectRow(at: 2, in: listViewController)

        // Then
        XCTAssertEqual(selectedRowIndices(in: listViewController), [2])
    }

    func test_performSubmit_withSelectedIssuer_shouldSubmitSelectedIssuer() throws {
        // Given
        paymentMethod = try makePaymentMethod(issuerCount: 3)
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        let listViewController = try presentList()
        selectRow(at: 1, in: listViewController)

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
        let details = try XCTUnwrap(delegateMock.didSubmitReceivedArguments?.data.paymentMethod as? IssuerListDetails)
        XCTAssertEqual(details.issuer, paymentMethod.issuers[1].identifier)
    }

    func test_performSubmit_withoutSelection_shouldShowError_andShouldNotSubmit() throws {
        // Given
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        _ = try presentList()

        // When
        sut.performSubmit()

        // Then
        XCTAssertFalse(delegateMock.didSubmitCalled)
        let errorLabel = try XCTUnwrap(errorLabel())
        XCTAssertFalse(errorLabel.isHidden)
        XCTAssertEqual(errorLabel.text, "Select an option to continue")
    }

    func test_selectingIssuer_afterSubmitWithoutSelection_shouldHideError() throws {
        // Given
        let listViewController = try presentList()
        sut.performSubmit()

        // When
        selectRow(at: 0, in: listViewController)

        // Then
        XCTAssertEqual(try XCTUnwrap(errorLabel()).isHidden, true)
    }

    func test_submitButtonTap_withSelectedIssuer_shouldSubmitAndShowLoading() throws {
        // Given
        paymentMethod = try makePaymentMethod(issuerCount: 3)
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        let listViewController = try presentList()
        selectRow(at: 2, in: listViewController)
        let button = try XCTUnwrap(submitButton())
        XCTAssertEqual(button.title, "Continue")

        // When
        button.sendActions(for: .touchUpInside)

        // Then
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
        let details = try XCTUnwrap(delegateMock.didSubmitReceivedArguments?.data.paymentMethod as? IssuerListDetails)
        XCTAssertEqual(details.issuer, paymentMethod.issuers[2].identifier)
        XCTAssertTrue(button.showsActivityIndicator)
        XCTAssertFalse(sut.viewController.view.isUserInteractionEnabled)
    }

    func test_stopLoading_afterSubmit_shouldStopButtonLoading() throws {
        // Given
        let listViewController = try presentList()
        selectRow(at: 0, in: listViewController)
        sut.performSubmit()

        // When
        sut.stopLoading()

        // Then
        XCTAssertFalse(try XCTUnwrap(submitButton()).showsActivityIndicator)
        XCTAssertTrue(sut.viewController.view.isUserInteractionEnabled)
    }

    func test_performSubmit_whenSubmitButtonHidden_shouldNotShowButton_andShouldSubmitSelectedIssuer() throws {
        // Given
        var configuration = IssuerListConfiguration()
        configuration.showsSubmitButton = false
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context, configuration: configuration)
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        let listViewController = try presentList()
        XCTAssertNil(submitButton())

        // When
        selectRow(at: 0, in: listViewController)
        XCTAssertFalse(delegateMock.didSubmitCalled)
        sut.performSubmit()

        // Then
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }

    func test_searchBar_withTenIssuers_shouldBeHidden() throws {
        // Given
        sut = try IssuerListComponent(paymentMethod: makePaymentMethod(issuerCount: 10), context: context)

        // When
        _ = try presentList()

        // Then
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        XCTAssertFalse(searchViewController.searchBar.isDescendant(of: searchViewController.view))
    }

    func test_searchBar_withMoreThanTenIssuers_shouldBeShown() throws {
        // Given
        sut = try IssuerListComponent(paymentMethod: makePaymentMethod(issuerCount: 11), context: context)

        // When
        _ = try presentList()

        // Then
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        XCTAssertTrue(searchViewController.searchBar.isDescendant(of: searchViewController.view))
    }

    func test_selection_whenSearchChanges_shouldBeKept() throws {
        // Given
        sut = try IssuerListComponent(paymentMethod: makePaymentMethod(issuerCount: 11), context: context)
        let listViewController = try presentList()
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "Issuer 11")

        // When
        selectRow(at: 0, in: listViewController)

        // Then
        XCTAssertEqual(listViewController.sections.flatMap(\.items).map(\.title), ["Test Issuer 11"])
        XCTAssertEqual(selectedRowIndices(in: listViewController), [0])

        // When
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "")

        // Then
        XCTAssertEqual(selectedRowIndices(in: listViewController), [10])
    }

    func test_selectingIssuer_shouldNotSendSearchEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        sut = IssuerListComponent(paymentMethod: paymentMethod, context: Dummy.context(analyticsProvider: analyticsProviderMock))
        let listViewController = try presentList()

        // When
        selectRow(at: 0, in: listViewController)
        wait(for: .seconds(1))

        // Then
        XCTAssertEqual(analyticsProviderMock.infos.map(\.type), [.rendered, .selected])
    }

    func test_component_afterPresentingAndSubmitting_shouldBeDeallocated() throws {
        // Given
        weak var weakComponent: IssuerListComponent?
        try autoreleasepool {
            let component = IssuerListComponent(paymentMethod: paymentMethod, context: context)
            weakComponent = component
            sut = component
            let listViewController = try presentList()
            selectRow(at: 0, in: listViewController)
            component.performSubmit()
            sut = nil
        }

        // When
        setupRootViewController(UIViewController())

        // Then
        XCTAssertNil(weakComponent)
    }

    func test_componentSendsInfo_onSearchInput_With_Throttling() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)

        sut = try IssuerListComponent(paymentMethod: makePaymentMethod(issuerCount: 11), context: context)
        
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        let listViewController = searchViewController.resultsListViewController
        
        setupRootViewController(searchViewController)
        
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "3")
        XCTAssertFalse(listViewController.view.isHidden)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        
        searchViewController.searchBar(searchViewController.searchBar, textDidChange: "34")
        // should not change before throttle delay passes
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        wait(for: .seconds(1))
        
        // should update after throttle delay
        XCTAssertTrue(listViewController.view.isHidden)
        XCTAssertEqual(analyticsProviderMock.infos.count, 2)
    }

    func test_ViewDidLoad_ShouldSend_InitialCall() {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)

        sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        let mockViewController = UIViewController()

        // When
        sut.viewDidLoad(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
    }
}

// MARK: - Helpers

private extension IssuerListComponentTests {

    func presentList() throws -> ListViewController {
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        setupRootViewController(searchViewController)
        return searchViewController.resultsListViewController
    }

    func selectRow(at index: Int, in listViewController: ListViewController) {
        let indexPaths = listViewController.sections.enumerated().flatMap { section, element in
            element.items.indices.map { IndexPath(item: $0, section: section) }
        }
        listViewController.tableView(listViewController.tableView, didSelectRowAt: indexPaths[index])
    }

    func makePaymentMethod(issuerCount: Int) throws -> IssuerListPaymentMethod {
        let issuers = (1...issuerCount).map { ["id": "issuer_\($0)", "name": "Test Issuer \($0)"] }
        return try AdyenCoder.decode(["type": "ideal", "name": "iDEAL", "issuers": issuers] as [String: Any])
    }

    func errorLabel() -> UILabel? {
        sut.viewController.view.findView(by: "errorLabel")
    }

    func submitButton() -> FormButton? {
        sut.viewController.view.findView(by: "submitButton")
    }

    func selectedRowIndices(in listViewController: ListViewController) -> [Int] {
        listViewController.sections
            .flatMap(\.items)
            .enumerated()
            .filter(\.element.isSelected)
            .map(\.offset)
    }
}
