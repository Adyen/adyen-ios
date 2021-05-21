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

    func testClientKeyValidationAssertion() {
        let sut = MockComponent()
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "The key you have provided to AdyenUIKitTests.AssertsTests.MockComponent is not a valid client key.\nCheck https://docs.adyen.com/user-management/client-side-authentication for more information.")
            expectation.fulfill()
        }

        sut.clientKey = "invalidClientKey"

        wait(for: [expectation], timeout: 2)

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
        let sut = AwaitComponent(style: nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent.")
            expectation.fulfill()
        }

        sut.handle(AwaitAction(paymentData: "", paymentMethodType: .blik))

        wait(for: [expectation], timeout: 2)

    }

    func testActionComponentAwaitActionNoClientKeyAssertion() {
        let sut = AdyenActionComponent()
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "Failed to instantiate AwaitComponent because client key is not configured.\nPlease supply the client key:\n-  if using DropInComponent, or AdyenActionsComponent.clientKey in the PaymentMethodsConfiguration;\n-  if using AdyenActionsComponent separately in AdyenActionsComponent.clientKey.")
            expectation.fulfill()
        }

        sut.handle(Action.await(AwaitAction(paymentData: "", paymentMethodType: .blik)))

        wait(for: [expectation], timeout: 2)

    }

    func testVoucherComponentPresentationDelegateAssertion() {
        let sut = VoucherComponent(style: nil)
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PresentationDelegate is nil. Provide a presentation delegate to VoucherAction.")
            expectation.fulfill()
        }

        sut.handle(VoucherAction.dokuAlfamart(DokuVoucherAction(paymentMethodType: .dokuAlfamart,
                                                                initialAmount: Amount(value: 100, currencyCode: ""),
                                                                totalAmount: Amount(value: 100, currencyCode: ""),
                                                                reference: "",
                                                                shopperEmail: "",
                                                                expiresAt: .distantFuture,
                                                                merchantName: "",
                                                                shopperName: "",
                                                                instructionsUrl: "")))

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
        let sut = ModalViewController(rootViewController: UIViewController())
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "PreferredContentSize is overridden for this view controller.\ngetter - returns combined size of an inner content and navigation bar.\nsetter - no implemented.")
            expectation.fulfill()
        }

        sut.preferredContentSize = .zero

        wait(for: [expectation], timeout: 2)

    }

    func testThreeDS2FingerprintSubmitterAssertion() {
        let sut = ThreeDS2FingerprintSubmitter()
        let expectation = XCTestExpectation(description: "Dummy Expectation")

        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "Client key is missing.")
            expectation.fulfill()
        }

        sut.submit(fingerprint: "", paymentData: nil, completionHandler: { _ in })

        wait(for: [expectation], timeout: 2)

    }

    class MockComponent: Component {}

}
