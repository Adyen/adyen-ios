//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
internal struct StoredPaymentMethodContentAssemblerTests {

    /// Any stored payment method gets its own stored payment screen to be completed on.
    @Test
    internal func storedComponent_whenResolved_thenReturnsContentRouter() {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )
        let sut = makeSUT()
        #expect(
            sut.resolveStoredPaymentMethodContentRouter(
                for: component,
                listener: ContentRouterListenerSpy()
            ) != nil
        )
    }

    /// A real stored payment method that needs no input at all, such as stored Cash App Pay, also gets
    /// the stored payment screen: it shows the payment method and a pay button, with nothing to fill in.
    @Test
    internal func storedComponentWithoutInput_whenResolved_thenReturnsContentRouter() {
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
        let sut = makeSUT()
        #expect(sut.resolveStoredPaymentMethodContentRouter(
            for: component,
            listener: ContentRouterListenerSpy()
        ) != nil)
    }

    /// Anything that is not a stored payment method gets nothing back. Returning nothing is how the
    /// assembler tells the list and preselected screens to present the component the generic way instead.
    @Test
    internal func componentThatIsNotStored_whenResolved_thenReturnsNil() {
        let component = PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"))
        let sut = makeSUT()
        #expect(sut.resolveStoredPaymentMethodContentRouter(
            for: component,
            listener: ContentRouterListenerSpy()
        ) == nil)
    }

    private func makeSUT() -> StoredPaymentMethodContentAssembler {
        StoredPaymentMethodContentAssembler(
            dropInFlowManager: DropInFlowManagingMock(),
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            theme: .default,
            localizationParameters: nil
        )
    }
}

@MainActor
private final class ContentRouterListenerSpy: StoredPaymentMethodContentRouterListener {
    func dismissStoredPaymentMethodContent() {}
}
