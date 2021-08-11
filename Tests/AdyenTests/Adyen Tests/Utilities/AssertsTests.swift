//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import XCTest

class AssertsTests: XCTestCase {

    override func tearDown() {
        AdyenAssertion.listener = nil
    }

    func testListViewControllerPreferredContentSizeAssertion() {
        let sut = ListViewController(style: ListComponentStyle())
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns content size of scroll view.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    func testFormViewControllerPreferredContentSizeAssertion() {
        let sut = FormViewController(style: FormComponentStyle())
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    func testAwaitViewControllerPreferredContentSizeAssertion() {
        let sut = AwaitViewController(viewModel: AwaitComponentViewModel(icon: "", message: "", spinnerTitle: ""))
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    func testAwaitVComponentPresentationDelegateAssertion() {
        let sut = AwaitComponent(apiContext: Dummy.context, style: nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent.")
            expectation.fulfill()
        }

        sut.handle(AwaitAction(paymentData: "", paymentMethodType: .blik))

        wait(for: [expectation], timeout: 2)

    }

    func testVoucherComponentPresentationDelegateAssertion() {
        let sut = VoucherComponent(apiContext: Dummy.context, style: nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent.")
            expectation.fulfill()
        }

        sut.handle(VoucherAction.dokuAlfamart(DokuVoucherAction(paymentMethodType: .dokuAlfamart,
                                                                initialAmount: Amount(value: 100, currencyCode: "USD"),
                                                                totalAmount: Amount(value: 100, currencyCode: "USD"),
                                                                reference: "",
                                                                shopperEmail: "",
                                                                expiresAt: .distantFuture,
                                                                merchantName: "",
                                                                shopperName: "",
                                                                instructionsUrl: URL(string: "https://google.com")!)))

        wait(for: [expectation], timeout: 2)

    }

    func testVoucherViewControllerPreferredContentSizeAssertion() {
        let sut = VoucherViewController(voucherView: UIView(), style: VoucherComponentStyle())
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    func testModalViewControllerPreferredContentSizeAssertion() {
        let sut = ModalViewController(rootViewController: UIViewController(), navBarType: .regular)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns combined size of an inner content and navigation bar.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    class MockComponent: Component {
        let apiContext: APIContext
        
        init(apiContext: APIContext = Dummy.context) {
            self.apiContext = apiContext
        }
    }

}
