//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenDropIn
import SafariServices
import XCTest

class DropInActionsTests: XCTestCase {

    var context: AdyenContext!
    var sut: DropInComponent!

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
        context = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testOpenRedirectActionOnDropIn() {
        let config = DropInComponent.Configuration()

        let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        let sut = DropInComponent(
            paymentMethods: paymentMethods,
            context: context,
            configuration: config
        )
        
        presentOnRoot(sut.viewController) {
            let action = Action.redirect(RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data"))
            sut.handle(action)
        }

        wait(until: { sut.viewController.adyen.topPresenter is SFSafariViewController })
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

        presentOnRoot(sut.viewController) {
            self.sut.didOpenExternalApplication(component: RedirectComponent(context: Dummy.context))
        }

        waitForExpectations(timeout: 15, handler: nil)
    }

}
