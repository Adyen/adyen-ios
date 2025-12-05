//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Testing
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
import UIKit

struct DropInFlowManagerTests {

    // MARK: - Helpers

    private func setupSUT() -> (
        sut: DropInFlowManager,
        dropInComponentDelegateMock: DropInComponentDelegateMock,
        configurationMock: DropInComponent.Configuration
    ) {
        let context = Dummy.context
        let dropInComponentMock = DropInComponent(paymentMethods: .init(regular: [], stored: []), context: context)
        let dropInComponentDelegateMock = DropInComponentDelegateMock()
        let configurationMock = DropInComponent.Configuration()
        let sut = DropInFlowManager(
            dropInComponent: dropInComponentMock,
            dropInComponentDelegate: dropInComponentDelegateMock,
            context: context,
            configuration: configurationMock
        )

        return (sut, dropInComponentDelegateMock, configurationMock)
    }

    private func makePaymentMethod() -> CardPaymentMethodMock {
        CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )
    }

    private func makePaymentComponentData(
        paymentMethod: CardPaymentMethodMock,
        amountValue: Int = 1000
    ) -> PaymentComponentData {
        let encryptedCard = EncryptedCard(
            number: "4111111111111111",
            securityCode: "737",
            expiryMonth: "03",
            expiryYear: "30"
        )

        let cardDetails = CardDetails(
            paymentMethod: paymentMethod,
            encryptedCard: encryptedCard,
            holderName: "Katrina del Mar"
        )

        let amount = Amount(value: amountValue, currencyCode: "EUR")
        return PaymentComponentData(paymentMethodDetails: cardDetails, amount: amount, order: nil)
    }

    // MARK: - Tests
 
    @Test func submitShouldCallDropInComponentDelegateDidSubmit() async throws {
        // Given
        let (sut, dropInComponentDelegateMock, _) = setupSUT()
        let paymentComponentDataMock = makePaymentComponentData(paymentMethod: makePaymentMethod())
        let paymentComponentMock = await PresentableComponentMock(
            paymentMethod: makePaymentMethod(),
            viewController: UIViewController()
        )
        let actionPresenterMock = ActionPresenterMock()

        // When
        sut.submit(
            paymentComponentDataMock,
            from: paymentComponentMock,
            actionPresenter: actionPresenterMock
        )

        #expect(dropInComponentDelegateMock.didSubmitFromInCallsCount == 1)
    }
}
