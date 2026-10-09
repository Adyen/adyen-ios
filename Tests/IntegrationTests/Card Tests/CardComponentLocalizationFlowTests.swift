//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
@_spi(AdyenInternal) @testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenCheckout
import XCTest

@MainActor
final class CardComponentLocalizationFlowTests: XCTestCase {

    private var context: AdyenContext {
        Dummy.context
    }

    private var paymentMethod: CardPaymentMethod {
        .init(
            type: .scheme,
            name: "Cards",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
    }

    func test_cardComponent_builtFromCheckoutConfiguration_withGlobalProviderAndSupportedLocale_shouldRenderVisibleLocalizedStrings() throws {
        let provider = CardComponentLocalizationFlowProviderMock(values: [.cardNumber: "Global number"])
        let localizationParameters = LocalizationParameters(enforcedLocale: "it-IT")

        let sut = try makeSUT(
            globalProvider: provider,
            localizationParameters: localizationParameters
        )

        expectVisibleTitles(
            of: sut,
            numberTitle: "Global number",
            securityCodeTitle: localizedString(.cardCvcItemTitle, localizationParameters)
        )
    }

    func test_cardComponent_builtFromCheckoutConfiguration_withGlobalProviderAndUnsupportedLocalePartialOverride_shouldMixCustomAndFallbackStrings() throws {
        let provider = CardComponentLocalizationFlowProviderMock(values: [.cardNumber: "Card #"])
        let localizationParameters = LocalizationParameters(enforcedLocale: "zu")

        let sut = try makeSUT(
            globalProvider: provider,
            localizationParameters: localizationParameters
        )

        expectVisibleTitles(
            of: sut,
            numberTitle: "Card #",
            securityCodeTitle: localizedString(.cardCvcItemTitle, localizationParameters)
        )
    }

    func test_cardComponent_builtFromCheckoutConfiguration_withoutProvider_shouldUseSDKDefaultLocalization() throws {
        let sut = try makeSUT()

        expectVisibleTitles(
            of: sut,
            numberTitle: localizedString(.cardNumberItemTitle, nil),
            securityCodeTitle: localizedString(.cardCvcItemTitle, nil)
        )
    }

    func test_cardComponent_builtFromCheckoutConfiguration_withGlobalProvider_shouldRenderCoBadgedSelectorStrings() throws {
        let provider = CardComponentLocalizationFlowProviderMock(values: [
            .cardDualBrandSelectorTitle: "Pick your card",
            .cardDualBrandSelectorDescription: "Choose the brand for this payment"
        ])

        let sut = try makeSUT(globalProvider: provider)

        XCTAssertEqual(sut.cardViewController.items.coBadgedCardItem.title, "Pick your card")
        XCTAssertEqual(sut.cardViewController.items.coBadgedCardItem.subtitle, "Choose the brand for this payment")
    }

    func test_cardComponent_builtFromCheckoutConfiguration_withGlobalProvider_shouldRenderInstallmentsStrings() throws {
        let provider = CardComponentLocalizationFlowProviderMock(values: [
            .cardInstallmentsTitle: "Custom payment plan",
            .cardInstallmentsPickerTitle: "Custom installments"
        ])

        var cardConfiguration = CardConfiguration()
        cardConfiguration.installmentConfiguration = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(monthValues: [2, 3], includesRevolving: false)
        )

        let sut = try makeSUT(
            configuration: cardConfiguration,
            globalProvider: provider
        )
        setupRootViewController(sut.viewController)

        XCTAssertEqual(sut.cardViewController.items.installmentsItem?.title, "Custom installments")
        XCTAssertNotNil(sectionHeaderView(containing: "Custom payment plan", in: sut.cardViewController.view))
    }

    private func makeSUT(
        configuration: CardConfiguration = .init(),
        globalProvider: (any CheckoutLocalizationProvider)? = nil,
        localizationParameters: LocalizationParameters? = nil
    ) throws -> CardComponent {
        var cardConfiguration = configuration
        cardConfiguration.localizationParameters = localizationParameters

        var checkoutConfiguration = makeCheckoutConfiguration(
            configurations: [.payment(.scheme): cardConfiguration]
        )

        if let globalProvider {
            checkoutConfiguration = checkoutConfiguration.localizationProvider(globalProvider)
        }

        return try makeBuiltCardComponent(checkoutConfiguration: checkoutConfiguration)
    }

    private func makeBuiltCardComponent(checkoutConfiguration: CheckoutConfiguration) throws -> CardComponent {
        let component = try CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            policy: .components(checkoutConfiguration),
            context: context
        )
        return try XCTUnwrap(component as? CardComponent)
    }

    private func makeCheckoutConfiguration(
        configurations: [CheckoutComponentType: CheckoutComponentConfiguration] = [:]
    ) -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            analyticsApiContext: nil,
            analyticsConfiguration: .init(),
            configurations: configurations
        )
    }

    private func expectVisibleTitles(
        of sut: CardComponent,
        numberTitle: String,
        securityCodeTitle: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let items = sut.cardViewController.items
        XCTAssertEqual(items.numberContainerItem.numberItem.title, numberTitle, file: file, line: line)
        XCTAssertEqual(items.securityCodeItem.title, securityCodeTitle, file: file, line: line)
    }

    private func sectionHeaderView(containing text: String, in view: UIView) -> FormSectionHeaderItemView? {
        if let sectionView = view as? FormSectionHeaderItemView, containsLabel(withText: text, in: sectionView) {
            return sectionView
        }
        for subview in view.subviews {
            if let found = sectionHeaderView(containing: text, in: subview) { return found }
        }
        return nil
    }

    private func containsLabel(withText text: String, in view: UIView) -> Bool {
        if let label = view as? UILabel, label.text == text { return true }
        return view.subviews.contains { containsLabel(withText: text, in: $0) }
    }
}

private final class CardComponentLocalizationFlowProviderMock: CheckoutLocalizationProvider {

    private let values: [CheckoutLocalizationKey: String]

    init(values: [CheckoutLocalizationKey: String]) {
        self.values = values
    }

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        values[key]
    }
}
