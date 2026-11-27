//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import Testing

/// Tests for the `showCardScanner` configuration option.
@MainActor
struct CardComponentShowCardScannerTests {

    @Test
    func default_showCardScanner_isTrue() {
        #expect(CardConfiguration().showCardScanner == true)
    }

    @Test(arguments: [true, false])
    func showCardScanner_default_scanCardHandlerMatchesScannerAvailability(isScannerAvailable: Bool) {
        let sut = Self.makeCardViewController(
            configuration: CardConfiguration(),
            cardScannerController: CardScannerControllerStub(isScannerAvailable: isScannerAvailable)
        )

        #expect((sut.items.numberContainerItem.numberItem.scanCardHandler != nil) == isScannerAvailable)
    }

    @Test
    func showCardScanner_disabled_noScanCardHandler() {
        let component = CardComponent(
            paymentMethod: Self.makeCardPaymentMethod(),
            context: Dummy.context,
            configuration: CardConfiguration().showCardScanner(false)
        )

        #expect(component.cardViewController.items.numberContainerItem.numberItem.scanCardHandler == nil)
    }

    @Test
    func showCardScanner_disabled_noScannerEventsSent() {
        let analyticsProvider = AnalyticsProviderMock()
        let component = CardComponent(
            paymentMethod: Self.makeCardPaymentMethod(),
            context: Dummy.context(analyticsProvider: analyticsProvider),
            configuration: CardConfiguration().showCardScanner(false)
        )
        component.viewDidLoad(viewController: component.cardViewController)

        #expect(analyticsProvider.logs.allSatisfy { $0.type != .cardScanner })
    }

    @Test
    func analytics_includesShowCardScanner() throws {
        let analyticsProvider = AnalyticsProviderMock()
        let component = CardComponent(
            paymentMethod: Self.makeCardPaymentMethod(),
            context: Dummy.context(analyticsProvider: analyticsProvider),
            configuration: CardConfiguration().showCardScanner(false)
        )
        component.viewDidLoad(viewController: component.cardViewController)

        let configData = try #require(analyticsProvider.infos.first?.configData?.stringOnlyDictionary)
        #expect(configData["showCardScanner"] == "false")
    }

    // MARK: - Private

    private static func makeCardPaymentMethod() -> CardPaymentMethod {
        CardPaymentMethod(
            type: .bcmc,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa]
        )
    }

    private static func makeCardViewController(
        configuration: CardConfiguration,
        cardScannerController: CardScannerControlling
    ) -> CardViewController {
        CardViewController(
            configuration: configuration,
            shopperInformation: nil,
            formStyle: FormComponentStyle(),
            amount: nil,
            logoProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            supportedCardBrands: [.visa],
            initialCountryCode: nil,
            scope: "test",
            localizationParameters: nil,
            theme: configuration.theme,
            cardScannerAnalyticsHandler: { _ in },
            cardScannerController: cardScannerController
        )
    }

    private final class CardScannerControllerStub: CardScannerControlling {
        internal init(isScannerAvailable: Bool) {
            self.isScannerAvailable = isScannerAvailable
        }

        var isScannerAvailable: Bool
        var title: String?
        var onScanComplete: ((Result<CardScannerCardDetails, Error>) -> Void)?
        func openCardScanner() { /* No-op */ }
        func dismiss(completion: (() -> Void)?) { /* No-op */ }
    }
}
