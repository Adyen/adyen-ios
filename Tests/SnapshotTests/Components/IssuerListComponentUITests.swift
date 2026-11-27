//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import SnapshotTesting
import XCTest

@MainActor
final class IssuerListComponentUITests: XCTestCase {

    private var context: AdyenContext {
        Dummy.context
    }

    private var paymentMethod: IssuerListPaymentMethod {
        try! AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod
    }

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func test_initialState() {
        let sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)

        setupRootViewController(sut.viewController)

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "initial_state")
    }

    func test_selectedState() throws {
        let sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        setupRootViewController(sut.viewController)

        try selectRow(at: 0, in: sut)

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "selected")
    }

    func test_submitWithoutSelection_shouldShowError() throws {
        let sut = try IssuerListComponent(paymentMethod: makePaymentMethod(issuerCount: 11), context: context)
        setupRootViewController(sut.viewController)

        sut.performSubmit()

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "error_with_search")
    }

    func test_submitWithSelection_shouldShowLoading() throws {
        let sut = IssuerListComponent(paymentMethod: paymentMethod, context: context)
        setupRootViewController(sut.viewController)
        try selectRow(at: 1, in: sut)

        sut.performSubmit()

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "loading")
    }

    private func selectRow(at index: Int, in sut: IssuerListComponent) throws {
        let searchViewController = try XCTUnwrap(sut.viewController as? SearchViewController)
        let items = searchViewController.resultsListViewController.sections.flatMap(\.items)
        let item = try XCTUnwrap(items.indices.contains(index) ? items[index] : nil)
        item.selectionHandler?()
    }

    private func makePaymentMethod(issuerCount: Int) throws -> IssuerListPaymentMethod {
        let issuers = (1...issuerCount).map { ["id": "issuer_\($0)", "name": "Test Issuer \($0)"] }
        return try AdyenCoder.decode(["type": "ideal", "name": "iDEAL", "issuers": issuers] as [String: Any])
    }
}
