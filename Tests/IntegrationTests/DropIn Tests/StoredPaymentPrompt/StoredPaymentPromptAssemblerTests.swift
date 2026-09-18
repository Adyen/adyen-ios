//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
internal struct StoredPaymentPromptAssemblerTests {

    @Test
    internal func componentRequiringInput_whenResolved_thenReturnsPrompt() {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )

        #expect(makeSUT().resolveStoredPaymentPromptRouter(
            for: component,
            presentationMode: .pushed,
            listener: ListenerSpy()
        ) != nil)
    }

    @Test
    internal func storedComponentWithoutInput_whenResolved_thenReturnsPrompt() {
        let component = StoredPaymentMethodComponent(
            paymentMethod: StoredCashAppPayPaymentMethod(
                type: .cashAppPay,
                name: "Cash App Pay",
                cashtag: "$arjenLandstra",
                identifier: "cash-app-id",
                supportedShopperInteractions: [.shopperPresent]
            ),
            context: Dummy.context
        )

        #expect(makeSUT().resolveStoredPaymentPromptRouter(
            for: component,
            presentationMode: .modal,
            listener: ListenerSpy()
        ) != nil)
    }

    @Test
    internal func componentWithoutInputThatIsNotStored_whenResolved_thenReturnsNil() {
        let component = PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"))

        #expect(makeSUT().resolveStoredPaymentPromptRouter(
            for: component,
            presentationMode: .pushed,
            listener: ListenerSpy()
        ) == nil)
    }

    private func makeSUT() -> StoredPaymentPromptAssembler {
        StoredPaymentPromptAssembler(
            dropInFlowManager: DropInFlowManagingMock(),
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            theme: .default,
            localizationParameters: nil
        )
    }
}

@MainActor
private final class ListenerSpy: StoredPaymentPromptRouterListener {
    func didDismissStoredPaymentPrompt() {}
}
