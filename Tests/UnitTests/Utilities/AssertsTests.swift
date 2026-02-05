//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class AssertsTests: XCTestCase {

    var context: AdyenContext!

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
    }

    override func tearDownWithError() throws {
        AdyenAssertion.listener = nil
        context = nil
        try super.tearDownWithError()
    }

    func testFormViewControllerPreferredContentSizeAssertion() {
        let sut = FormViewController(
            scrollEnabled: true,
            style: FormComponentStyle(),
            localizationParameters: nil
        )
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 10)

    }

    func testAwaitViewControllerPreferredContentSizeAssertion() {
        let sut = AwaitViewController(viewModel: AwaitComponentViewModel(icon: "", message: "", spinnerTitle: ""))
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 10)

    }

    func testAwaitVComponentPresentationDelegateAssertion() {
        let sut = AwaitComponent(context: context)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent.")
            expectation.fulfill()
        }

        sut.handle(AwaitAction(paymentData: "", paymentMethodType: .blik))

        wait(for: [expectation], timeout: 10)

    }

    func testVoucherComponentPresentationDelegateAssertion() throws {
        let sut = VoucherComponent(context: context)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent.")
            expectation.fulfill()
        }

        try sut.handle(VoucherAction.dokuAlfamart(DokuVoucherAction(
            paymentMethodType: .dokuAlfamart,
            initialAmount: Amount(value: 100, currencyCode: "USD"),
            totalAmount: Amount(value: 100, currencyCode: "USD"),
            reference: "",
            shopperEmail: "",
            expiresAt: .distantFuture,
            merchantName: "",
            shopperName: "",
            instructionsUrl: XCTUnwrap(URL(string: "https://google.com"))
        )))

        wait(for: [expectation], timeout: 10)

    }

    func testVoucherViewControllerPreferredContentSizeAssertion() {
        let sut = VoucherViewController(voucherView: UIView(), style: VoucherComponentStyle())
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns minimum possible content size.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 10)

    }

    class MockComponent: Component {
        let context: AdyenContext
        
        init(context: AdyenContext = Dummy.context) {
            self.context = context
        }
    }

}
