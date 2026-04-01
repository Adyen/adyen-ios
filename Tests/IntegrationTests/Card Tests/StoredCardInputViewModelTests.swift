//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import Combine
import Testing
import UIKit

@MainActor
struct StoredCardInputViewModelTests {

    // MARK: - Analytics Events

    @Test(arguments: StoredCardTestData.allBrands)
    func viewDidLoad_sendsDidLoadEvent(brand: CardType) throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(brand: brand, analyticsProvider: analyticsProviderMock)

        // When
        sut.viewDidLoad()

        // Then
        #expect(analyticsProviderMock.infos.count == 1)
        let infoEvent = try #require(analyticsProviderMock.infos.first)
        #expect(infoEvent.component == PaymentMethodType.card.rawValue)
        #expect(infoEvent.type == .rendered)
        #expect(infoEvent.isStoredPaymentMethod == true)
        #expect(infoEvent.brand == brand.rawValue)
    }

    @Test
    func viewDidLoad_withoutAnalyticsProvider() {
        // Given
        let sut = makeSUT(analyticsProvider: nil)

        // When / Then - no crash
        sut.viewDidLoad()
    }

    @Test
    func submitPayment_encryptionFailure_sendsErrorEvent() async throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(publicKey: "invalid_public_key", analyticsProvider: analyticsProviderMock)
        sut.securityCodeItem.value = "737"

        // When
        await withCheckedContinuation { continuation in
            sut.cardDetailsCompletionHandler = { _ in continuation.resume() }
            Task { await sut.submitPayment(securityCode: "737") }
        }

        // Then
        #expect(analyticsProviderMock.errors.count == 1)
        let errorEvent = try #require(analyticsProviderMock.errors.first)
        #expect(errorEvent.component == PaymentMethodType.card.rawValue)
    }

    // MARK: - UI Text

    @Test
    func textProperties() {
        // Given
        let amount = Amount(value: 14098, currencyCode: "USD")
        let sut = makeSUT(name: "VISA", lastFour: "4556", amount: amount)

        // Then
        #expect(!sut.titleText.isEmpty)

        // subtitleText contains payment method info and formatted amount
        let subtitle = sut.subtitleText.string
        #expect(subtitle == "Enter the security code for VISA •••• 4556 to complete the payment of $140.98")
        // submitButtonTitle contains formatted amount
        #expect(sut.submitButtonTitle.contains("$140.98"))
    }

    @Test(arguments: StoredCardTestData.amounts)
    func submitButtonTitle_formatsAmounts(amountData: StoredCardTestData.AmountData) {
        // Given
        let sut = makeSUT(amount: amountData.amount)

        // Then
        #expect(sut.submitButtonTitle.contains(amountData.expectedFormatted))
    }

    // MARK: - Navigation & Reset

    @Test func dismiss_invokesHandlerAndResets() {
        // Given
        let sut = makeSUT()
        sut.securityCodeItem.value = "737"
        var closeHandlerCalled = false
        sut.closeHandler = { closeHandlerCalled = true }

        // When
        sut.dismiss()

        // Then
        #expect(closeHandlerCalled)
        #expect(sut.securityCodeItem.value == "")
    }

    @Test
    func dismiss_resetsSecurityCode() {
        // Given
        let sut = makeSUT()
        sut.securityCodeItem.value = "999"
        sut.closeHandler = {}

        // When
        sut.dismiss()

        // Then
        #expect(sut.securityCodeItem.value == "", "Security code should be cleared after dismiss")
    }

    @Test func navigation_withoutHandlers_doesNotCrash() {
        // Given
        let sut = makeSUT()
        sut.closeHandler = nil

        // When / Then - no crash
        sut.dismiss()
    }

    // MARK: - Submit Payment

    @Test func submitPayment_success() async throws {
        // Given
        let sut = makeSUT(publicKey: Dummy.publicKey)

        let result: Result<CardDetails, Error> = try await withCheckedThrowingContinuation { continuation in
            sut.cardDetailsCompletionHandler = { continuation.resume(returning: $0) }
            Task {
                // When
                await sut.submitPayment(securityCode: "737")
            }
        }

        // Then
        let cardDetails = try result.get()
        #expect(cardDetails.encryptedSecurityCode != nil)
    }

    @Test func submitPayment_encryptionFailure_reportsError() async {
        // Given
        let sut = makeSUT(publicKey: "invalid_key")

        // When
        let result: Result<CardDetails, Error> = await withCheckedContinuation { continuation in
            sut.cardDetailsCompletionHandler = { continuation.resume(returning: $0) }
            Task {
                await sut.submitPayment(securityCode: "737")
            }
        }

        // Then
        switch result {
        case .success: Issue.record("Expected failure but got success")
        case .failure: break
        }
    }

    // MARK: - View callbacks

    @Test
    func submit_invalidSecurityCode_requestsSecurityCodeValidation() async {
        // Given
        let sut = makeSUT()
        var showValidationCallsCount = 0
        sut.onSecurityCodeValidationRequested = { showValidationCallsCount += 1 }

        // When
        sut.securityCodeItem.value = ""
        await sut.submit()

        // Then
        #expect(showValidationCallsCount == 1)
        #expect(!sut.inProgress)
    }

    @Test
    func submit_validSecurityCode_doesNotRequestSecurityCodeValidation() async {
        // Given
        let sut = makeSUT(publicKey: Dummy.publicKey)
        var showValidationCallsCount = 0
        sut.onSecurityCodeValidationRequested = { showValidationCallsCount += 1 }

        // When
        sut.securityCodeItem.value = "737"
        await sut.submit()

        // Then
        #expect(showValidationCallsCount == 0)
    }

    @Test
    func submit_validSecurityCode_togglesInProgressPublisher() async {
        // Given
        let sut = makeSUT(publicKey: Dummy.publicKey)
        var receivedProgress: [Bool] = []
        let cancellable = sut.inProgressPublisher
            .dropFirst()
            .sink { receivedProgress.append($0) }
        defer { cancellable.cancel() }

        // When
        sut.securityCodeItem.value = "737"
        await sut.submit()

        // Then
        #expect(receivedProgress == [true, false])
        #expect(!sut.inProgress)
    }

    // MARK: - Helpers

    private func makeSUT(
        name: String = "VISA",
        lastFour: String = "1111",
        brand: CardType = .visa,
        amount: Amount? = Amount(value: 100, currencyCode: "EUR"),
        publicKey: String = Dummy.publicKey,
        analyticsProvider: AnyAnalyticsProvider? = AnalyticsProviderMock()
    ) -> StoredCardInputViewModel {
        let storedCardPaymentMethod = StoredCardPaymentMethod(
            type: .card,
            name: name,
            identifier: "test_id",
            fundingSource: .credit,
            supportedShopperInteractions: [.shopperPresent],
            brand: brand,
            lastFour: lastFour,
            expiryMonth: "12",
            expiryYear: "2030",
            holderName: "Test Holder"
        )

        return StoredCardInputViewModel(
            theme: .default,
            storedCardPaymentMethod: storedCardPaymentMethod,
            apiContext: Dummy.apiContext,
            publicKey: publicKey,
            amount: amount,
            analyticsProvider: analyticsProvider,
            localizationParameters: nil
        )
    }
}

// MARK: - Test Data

enum StoredCardTestData {

    static let allBrands: [CardType] = [.visa, .masterCard, .americanExpress, .other(named: "abcdef")]

    struct AmountData: CustomTestStringConvertible {
        let amount: Amount
        let expectedFormatted: String

        var testDescription: String {
            "\(amount.currencyCode) \(amount.value) -> \(expectedFormatted)"
        }
    }

    static let amounts: [AmountData] = [
        AmountData(amount: Amount(value: 100, currencyCode: "EUR"), expectedFormatted: "€1.00"),
        AmountData(amount: Amount(value: 14098, currencyCode: "USD"), expectedFormatted: "$140.98"),
        AmountData(amount: Amount(value: 0, currencyCode: "GBP"), expectedFormatted: "£0.00")
    ]
}
