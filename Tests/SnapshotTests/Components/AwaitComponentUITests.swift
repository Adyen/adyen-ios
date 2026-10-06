//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class AwaitComponentUITests: XCTestCase {

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

    func testUIForBlik() {
        verifyAwaitScreen(for: .blik, theme: .default, named: "blik")
    }

    func testUIWithCustomTheme() {
        let theme = CheckoutTheme(
            colors: CheckoutColors(
                background: .lightGray,
                primary: .brown,
                disabled: .cyan,
                text: .red,
                textSecondary: .blue
            )
        )
        verifyAwaitScreen(for: .mbway, theme: theme, named: "mbway_customTheme")
    }

    // MARK: - Private

    private func verifyAwaitScreen(for paymentMethodType: AwaitPaymentMethod, theme: CheckoutTheme, named name: String) {
        let presentationExpectation = expectation(description: "Await screen presented")

        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let sut = AwaitComponent(
            context: Dummy.context,
            action: AwaitAction(paymentData: "data", paymentMethodType: paymentMethodType),
            actionPresentationDelegate: actionPresentationDelegate,
            configuration: .init(theme: theme)
        )

        actionPresentationDelegate.doPresent = { viewController in
            self.setupRootViewController(viewController)
            self.verifyViewControllerImage(matching: viewController, named: name)
            presentationExpectation.fulfill()
        }

        sut.handle()

        waitForExpectations(timeout: 10, handler: nil)
    }
}
