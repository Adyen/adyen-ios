//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import Testing

/// Tests for the `showCardScanner` configuration option.
@MainActor
struct CardComponentShowCardScannerTests {

    @Test
    func default_showCardScanner_isTrue() {
        #expect(CardConfiguration().showCardScanner == true)
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
}
