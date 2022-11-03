//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenDropIn
import SafariServices
import XCTest

class DropInActionsTests: XCTestCase {

    var context: AdyenContext!
    var sut: DropInComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        context = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testOpenRedirectActionOnDropIn() {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymentMethods,
                              context: context,
                              configuration: config)

        let waitExpectation = expectation(description: "Expect SafariViewController to open")
        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root
        root.present(sut.viewController, animated: true, completion: {
            let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
            self.sut.handle(action)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                XCTAssertNotNil(self.sut.viewController.adyen.topPresenter as? SFSafariViewController)
                waitExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testOpenExternalApp() {
        let config = DropInComponent.Configuration()

        let waitExpectation = expectation(description: "Expect a callback")
        let mock = DropInDelegateMock()

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        sut = DropInComponent(paymentMethods: paymenMethods,
                              context: context,
                              configuration: config)
        sut.delegate = mock

        mock.didOpenExternalApplicationHandler = { _ in
            waitExpectation.fulfill()
        }

        let root = UIViewController()
        UIApplication.shared.keyWindow?.rootViewController = root

        root.present(sut.viewController, animated: true) {
            self.sut.didOpenExternalApplication(component: RedirectComponent(context: Dummy.context))
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

}
