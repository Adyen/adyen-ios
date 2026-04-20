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
    func textUI_WhenAmountIsAvailable() {
        // Given
        let amount = Amount(value: 14098, currencyCode: "USD")
        let expectedTitle = "Enter security code"
        let expectedSubTitle = "Enter the security code for VISA \(String.Adyen.securedString)4556"
        let expectedButtonTitle = "Pay $140.98"
        let sut = makeSUT(name: "VISA", lastFour: "4556", amount: amount)

        // Then
        #expect(sut.titleText == expectedTitle)
        #expect(sut.subtitleText.string == expectedSubTitle)
        #expect(sut.submitButtonTitle == expectedButtonTitle)
    }

    @Test
    func textUI_WhenAmountIsZero() {
        // Given
        let amount = Amount(value: 0, currencyCode: "USD")
        let expectedTitle = "Enter security code"
        let expectedSubTitle = "Enter the security code for VISA \(String.Adyen.securedString)4556"
        let expectedButtonTitle = "Confirm preauthorization"
        let sut = makeSUT(name: "VISA", lastFour: "4556", amount: amount)

        // Then
        #expect(sut.titleText == expectedTitle)
        #expect(sut.subtitleText.string == expectedSubTitle)
        #expect(sut.submitButtonTitle == expectedButtonTitle)
    }

    @Test
    func textUI_WhenAmountIsNil() {
        // Given
        let expectedTitle = "Enter security code"
        let expectedSubTitle = "Enter the security code for VISA \(String.Adyen.securedString)4556"
        let expectedButtonTitle = "Pay"
        let sut = makeSUT(name: "VISA", lastFour: "4556", amount: nil)

        // Then
        #expect(sut.titleText == expectedTitle)
        #expect(sut.subtitleText.string == expectedSubTitle)
        #expect(sut.submitButtonTitle == expectedButtonTitle)
    }

    @Test(arguments: StoredCardTestData.amounts)
    func submitButtonTitle_formatsAmounts(amountData: StoredCardTestData.AmountData) {
        // Given
        let sut = makeSUT(amount: amountData.amount)

        // Then
        #expect(sut.submitButtonTitle.contains(amountData.expectedFormatted))
    }

    // MARK: - Custom Localization

    /// Verifies that the view model correctly uses custom localization strings when a custom table name is provided.
    ///
    /// This test ensures merchants can override the default SDK strings by providing their own `.strings` file.
    /// The test uses `AdyenUIHost.strings` which contains custom translations prefixed with "Test-".
    @Test
    func localizationWithCustomTableName() {
        // Given
        let localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let amount = Amount(value: 300, currencyCode: "EUR")
        let sut = makeSUT(
            name: "VISA",
            lastFour: "1111",
            amount: amount,
            localizationParameters: localizationParameters
        )

        let expectedTitleText = "Test-Enter security code"
        let expectedSubtitleText = "Test-Enter the security code for VISA \(String.Adyen.securedString)1111"
        let expectedSubmitButtonTitle = "Test-Pay €3.00"

        // Then
        #expect(sut.titleText == expectedTitleText)
        #expect(sut.subtitleText.string == expectedSubtitleText)
        #expect(sut.submitButtonTitle == expectedSubmitButtonTitle)
    }

    /// Verifies that the view model correctly handles custom key separators in localization keys.
    ///
    /// This test ensures the SDK supports alternative key formats where dots (`.`) are replaced with
    /// underscores (`_`) or other separators. This is useful for merchants whose localization systems
    /// don't support dots in key names.
    ///
    /// The test uses `AdyenUIHostCustomSeparator.strings` where keys use underscores instead of dots
    /// (e.g., `adyen_card_securityCode_title` instead of `adyen.card.securityCode.title`).
    @Test
    func localizationWithCustomKeySeparator() {
        // Given
        let localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let amount = Amount(value: 300, currencyCode: "EUR")
        let sut = makeSUT(
            name: "VISA",
            lastFour: "1111",
            amount: amount,
            localizationParameters: localizationParameters
        )

        let expectedTitleText = "Test-Enter security code"
        let expectedSubtitleText = "Test-Enter the security code for VISA \(String.Adyen.securedString)1111"
        let expectedSubmitButtonTitle = "Test-Pay €3.00"

        // Then
        #expect(sut.titleText == expectedTitleText)
        #expect(sut.subtitleText.string == expectedSubtitleText)
        #expect(sut.submitButtonTitle == expectedSubmitButtonTitle)
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
        #expect(sut.securityCodeItem.value.isEmpty)
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
        #expect(sut.securityCodeItem.value.isEmpty, "Security code should be cleared after dismiss")
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
        analyticsProvider: AnyAnalyticsProvider? = AnalyticsProviderMock(),
        localizationParameters: LocalizationParameters? = nil
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
            localizationParameters: localizationParameters
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
        AmountData(amount: Amount(value: 14098, currencyCode: "USD"), expectedFormatted: "$140.98")
    ]
}
