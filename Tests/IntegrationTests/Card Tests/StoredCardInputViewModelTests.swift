//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
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
        // titleText
        #expect(!sut.titleText.isEmpty)

        // subtitleText contains payment method info and formatted amount
        let subtitle = sut.subtitleText.string
        #expect(subtitle.contains("VISA"))
        #expect(subtitle.contains("4556"))
        #expect(subtitle.contains("$140.98"))

        // submitButtonTitle contains formatted amount
        #expect(sut.submitButtonTitle.contains("$140.98"))

        // showAllPaymentMethodsButtonTitle
        #expect(!sut.showAllPaymentMethodsButtonTitle.isEmpty)
    }

    @Test(arguments: StoredCardTestData.amounts)
    func submitButtonTitle_formatsAmounts(amountData: StoredCardTestData.AmountData) {
        // Given
        let sut = makeSUT(amount: amountData.amount)

        // Then
        #expect(sut.submitButtonTitle.contains(amountData.expectedFormatted))
    }

    @Test func subtitleText_nilAmount() {
        // Given
        let sut = makeSUT(amount: nil)

        // Then
        #expect(!sut.subtitleText.string.isEmpty)
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

    @Test func showAllPaymentMethods_invokesHandlerAndResets() {
        // Given
        let sut = makeSUT()
        sut.securityCodeItem.value = "123"
        var handlerCalled = false
        sut.otherPaymentOptionsHandler = { handlerCalled = true }

        // When
        sut.showAllPaymentMethods()

        // Then
        #expect(handlerCalled)
        #expect(sut.securityCodeItem.value == "")
    }

    @Test(arguments: NavigationAction.allCases)
    func navigatingAway_resetsSecurityCode(action: NavigationAction) {
        // Given
        let sut = makeSUT()
        sut.securityCodeItem.value = "999"
        sut.closeHandler = {}
        sut.otherPaymentOptionsHandler = {}

        // When
        switch action {
        case .dismiss: sut.dismiss()
        case .showAllPaymentMethods: sut.showAllPaymentMethods()
        }

        // Then
        #expect(sut.securityCodeItem.value == "", "Security code should be cleared after \(action)")
    }

    @Test func navigation_withoutHandlers_doesNotCrash() {
        // Given
        let sut = makeSUT()
        sut.closeHandler = nil
        sut.otherPaymentOptionsHandler = nil

        // When / Then - no crash
        sut.dismiss()
        sut.showAllPaymentMethods()
    }

    // MARK: - Submit Payment

    @Test func submitPayment_success() async throws {
        // Given
        let sut = makeSUT(publicKey: Dummy.publicKey)

        // When
        let result: Result<CardDetails, Error> = try await withCheckedThrowingContinuation { continuation in
            sut.cardDetailsCompletionHandler = { continuation.resume(returning: $0) }
            Task { await sut.submitPayment(securityCode: "737") }
        }

        // Then
        let cardDetails = try result.get()
        #expect(cardDetails.encryptedSecurityCode != nil)
        #expect(cardDetails.encryptedCardNumber == nil)
        #expect(cardDetails.encryptedExpiryMonth == nil)
        #expect(cardDetails.encryptedExpiryYear == nil)
    }

    @Test func submitPayment_encryptionFailure_reportsError() async {
        // Given
        let sut = makeSUT(publicKey: "invalid_key")

        // When
        let result: Result<CardDetails, Error> = await withCheckedContinuation { continuation in
            sut.cardDetailsCompletionHandler = { continuation.resume(returning: $0) }
            Task { await sut.submitPayment(securityCode: "737") }
        }

        // Then
        switch result {
        case .success: Issue.record("Expected failure but got success")
        case .failure: break
        }
    }

    // MARK: - Security Code Observer & Card Image

    @Test
    func submit_invalidSecurityCode_requestsValidationInstruction() async {
        // Given
        let sut = makeSUT()
        var receivedInstructions: [StoredCardInputViewInstruction] = []
        sut.onViewInstruction = { receivedInstructions.append($0) }

        // When
        sut.securityCodeItem.value = ""
        await sut.submit()

        // Then
        #expect(receivedInstructions == [.showSecurityCodeValidation])
    }

    @Test
    func submit_validSecurityCode_togglesLoadingInstructions() async {
        // Given
        let sut = makeSUT(publicKey: Dummy.publicKey)
        var receivedInstructions: [StoredCardInputViewInstruction] = []
        sut.onViewInstruction = { receivedInstructions.append($0) }

        // When
        sut.securityCodeItem.value = "737"
        await sut.submit()

        // Then
        #expect(receivedInstructions == [.setLoading(true), .setLoading(false)])
    }

    @Test
    func cardImageItem_hasFixedSize() {
        // Given
        let sut = makeSUT()
        let expectedSize = CGSize(width: 80, height: 52)

        // Then
        if case let .fixed(size) = sut.cardImageItem.sizeMode {
            #expect(size == expectedSize)
        } else {
            Issue.record("Expected fixed size mode")
        }
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

enum NavigationAction: CaseIterable, CustomTestStringConvertible {
    case dismiss
    case showAllPaymentMethods

    var testDescription: String {
        switch self {
        case .dismiss: "dismiss"
        case .showAllPaymentMethods: "showAllPaymentMethods"
        }
    }
}

enum StoredCardTestData {

    static let allBrands: [CardType] = [.visa, .masterCard, .americanExpress]

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

// MARK: - StoredCardInputViewControllerTests

@MainActor
struct StoredCardInputViewControllerTests {

    // MARK: - A: UI Display

    @Test
    func viewDidLoad_callsViewModelViewDidLoad() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()
        #expect(viewModel.viewDidLoadCallsCount == 1)
    }

    @Test
    func viewDidLoad_configuresLabelsAndButtonsFromViewModel() throws {
        let titleText = "Enter security code"
        let subtitleText = "Use your Visa card"
        let submitTitle = "Pay €9.99"
        let otherTitle = "Other payment options"

        let (proxy, _) = makeSUT(
            titleText: titleText,
            subtitleText: subtitleText,
            submitButtonTitle: submitTitle,
            showAllPaymentMethodsButtonTitle: otherTitle
        )
        proxy.load()

        #expect(try proxy.titleLabelText == titleText)
        #expect(try proxy.subtitleLabelText == subtitleText)
        #expect(try proxy.primaryButtonTitle == submitTitle)
        #expect(try proxy.secondaryButtonTitle == otherTitle)
    }

    @Test
    func viewDidLoad_setsIsModalInPresentation() {
        let (proxy, _) = makeSUT()
        proxy.load()
        #expect(proxy.viewController.isModalInPresentation)
    }

    @Test
    func viewDidLoad_hasBackNavigationButton() {
        let (proxy, _) = makeSUT()
        proxy.load()
        #expect(proxy.viewController.navigationItem.leftBarButtonItem != nil)
    }

    // MARK: - B: Primary button tap

    @Test
    func primaryButtonTap_callsSubmit() async throws {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        try proxy.tapPrimaryButton()

        // submit is dispatched inside a Task — yield to let it run
        for _ in 0..<10 {
            await Task.yield()
        }

        #expect(viewModel.submitCallsCount == 1)
    }

    // MARK: - C: View instructions → UI

    @Test
    func viewInstruction_setLoadingTrue_disablesButtonAndShowsSpinner() throws {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        viewModel.onViewInstruction?(.setLoading(true))

        let button = try proxy.primaryButton()
        #expect(button.showsActivityIndicator)
        #expect(!button.isEnabled)
    }

    @Test
    func viewInstruction_setLoadingFalse_enablesButtonAndHidesSpinner() throws {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        viewModel.onViewInstruction?(.setLoading(true))
        viewModel.onViewInstruction?(.setLoading(false))

        let button = try proxy.primaryButton()
        #expect(!button.showsActivityIndicator)
        #expect(button.isEnabled)
    }

    @Test
    func viewInstruction_showSecurityCodeValidation_setsInvalidStateOnItem() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        viewModel.onViewInstruction?(.showSecurityCodeValidation)

        if case .invalid = viewModel.securityCodeItem.validationState {
            // pass
        } else {
            Issue.record("Expected validationState to be .invalid after showSecurityCodeValidation instruction")
        }
    }

    // MARK: - D: Secondary button and back button

    @Test
    func secondaryButtonTap_callsShowAllPaymentMethods() throws {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        try proxy.tapSecondaryButton()

        #expect(viewModel.showAllPaymentMethodsCallsCount == 1)
    }

    @Test
    func backButtonTap_callsDismiss() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        proxy.tapBackButton()

        #expect(viewModel.dismissCallsCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        titleText: String = "Enter security code",
        subtitleText: String = "Use your Visa card",
        submitButtonTitle: String = "Pay €1.00",
        showAllPaymentMethodsButtonTitle: String = "Other payment options"
    ) -> (proxy: StoredCardInputViewControllerProxy, viewModel: StoredCardInputViewModelProtocolMock) {
        let viewModel = StoredCardInputViewModelProtocolMock()
        viewModel.underlyingTitleText = titleText
        viewModel.underlyingSubtitleText = NSAttributedString(string: subtitleText)
        viewModel.underlyingSubmitButtonTitle = submitButtonTitle
        viewModel.underlyingShowAllPaymentMethodsButtonTitle = showAllPaymentMethodsButtonTitle
        viewModel.underlyingTheme = .default
        viewModel.underlyingSecurityCodeItem = FormCardSecurityCodeItem()
        viewModel.underlyingCardImageItem = CardImageItem(
            imageURL: nil,
            sizeMode: .fixed(CGSize(width: 80, height: 52)),
            theme: .default
        )

        let viewController = StoredCardInputViewController(viewModel: viewModel)
        return (StoredCardInputViewControllerProxy(viewController: viewController), viewModel)
    }
}

// MARK: - StoredCardInputViewControllerProxy

@MainActor
struct StoredCardInputViewControllerProxy {
    let viewController: StoredCardInputViewController

    func load() {
        viewController.loadViewIfNeeded()
    }

    var titleLabelText: String {
        get throws {
            let label = try #require(
                viewController.view.findView(by: "title") as? UILabel,
                "Cannot find title label"
            )
            return try #require(label.text)
        }
    }

    var subtitleLabelText: String {
        get throws {
            let label = try #require(
                viewController.view.findView(by: "subTitle") as? UILabel,
                "Cannot find subtitle label"
            )
            return try #require(label.attributedText?.string)
        }
    }

    var primaryButtonTitle: String {
        get throws {
            let button = try primaryButton()
            return try #require(button.title)
        }
    }

    var secondaryButtonTitle: String {
        get throws {
            let button = try secondaryButton()
            return try #require(button.title)
        }
    }

    func primaryButton() throws -> FormButton {
        try #require(
            viewController.view.findView(by: "primaryButton") as? FormButton,
            "Cannot find primaryButton"
        )
    }

    func secondaryButton() throws -> FormButton {
        try #require(
            viewController.view.findView(by: "secondaryButton") as? FormButton,
            "Cannot find secondaryButton"
        )
    }

    func tapPrimaryButton() throws {
        try primaryButton().sendActions(for: .touchUpInside)
    }

    func tapSecondaryButton() throws {
        try secondaryButton().sendActions(for: .touchUpInside)
    }

    func tapBackButton() {
        let backButton = viewController.navigationItem.leftBarButtonItem
        _ = backButton?.target?.perform(backButton?.action)
    }
}

// MARK: - StoredCardInputViewModelProtocolMock

class StoredCardInputViewModelProtocolMock: StoredCardInputViewModelProtocol {

    var cardImageItem: CardImageItem {
        get { underlyingCardImageItem }
        set(value) { underlyingCardImageItem = value }
    }

    var underlyingCardImageItem: CardImageItem!

    var titleText: String {
        get { underlyingTitleText }
        set(value) { underlyingTitleText = value }
    }

    var underlyingTitleText: String! = ""

    var subtitleText: NSAttributedString {
        get { underlyingSubtitleText }
        set(value) { underlyingSubtitleText = value }
    }

    var underlyingSubtitleText: NSAttributedString! = NSAttributedString()

    var securityCodeItem: FormCardSecurityCodeItem {
        get { underlyingSecurityCodeItem }
        set(value) { underlyingSecurityCodeItem = value }
    }

    var underlyingSecurityCodeItem: FormCardSecurityCodeItem! = FormCardSecurityCodeItem()

    var submitButtonTitle: String {
        get { underlyingSubmitButtonTitle }
        set(value) { underlyingSubmitButtonTitle = value }
    }

    var underlyingSubmitButtonTitle: String! = ""

    var showAllPaymentMethodsButtonTitle: String {
        get { underlyingShowAllPaymentMethodsButtonTitle }
        set(value) { underlyingShowAllPaymentMethodsButtonTitle = value }
    }

    var underlyingShowAllPaymentMethodsButtonTitle: String! = ""

    var theme: AdyenTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: AdyenTheme! = .default

    var onViewInstruction: ((StoredCardInputViewInstruction) -> Void)?

    // MARK: - submit

    var submitCallsCount = 0
    var submitCalled: Bool {
        submitCallsCount > 0
    }

    var submitClosure: (() async -> Void)?

    @MainActor
    func submit() async {
        submitCallsCount += 1
        await submitClosure?()
    }

    // MARK: - showAllPaymentMethods

    var showAllPaymentMethodsCallsCount = 0
    var showAllPaymentMethodsCalled: Bool {
        showAllPaymentMethodsCallsCount > 0
    }

    var showAllPaymentMethodsClosure: (() -> Void)?

    @MainActor
    func showAllPaymentMethods() {
        showAllPaymentMethodsCallsCount += 1
        showAllPaymentMethodsClosure?()
    }

    // MARK: - dismiss

    var dismissCallsCount = 0
    var dismissCalled: Bool {
        dismissCallsCount > 0
    }

    var dismissClosure: (() -> Void)?

    @MainActor
    func dismiss() {
        dismissCallsCount += 1
        dismissClosure?()
    }

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    var viewDidLoadClosure: (() -> Void)?

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
        viewDidLoadClosure?()
    }
}
