//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

@MainActor
final class ComponentManagerTests: XCTestCase {

    private var context: AdyenContext!
    private var configuration: DropInConfiguration!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context
        configuration = DropInConfiguration()
    }

    override func tearDownWithError() throws {
        AdyenAssertion.listener = nil
        context = nil
        configuration = nil
        try super.tearDownWithError()
    }

    func test_supportedMethods_withCheckoutBuilder_includeSupportedRegularAndStoredMethods() throws {
        let methods = try supportedPaymentMethods()
        let sut = try makeSUT(
            paymentMethods: methods,
            paymentComponentProvider: checkoutProvider(includingApplePay: true)
        )

        XCTAssertEqual(
            sut.supportedRegularPaymentMethods.map(\.type),
            methods.regular.map(\.type)
        )
        XCTAssertEqual(
            sut.supportedStoredPaymentMethods.map(\.identifier),
            methods.stored.map(\.identifier)
        )
    }

    func test_supportedMethods_withCheckoutBuilder_omitUnsupportedRegularMethods() throws {
        let unsupportedMethod = try AdyenCoder.decode(issuerListDictionary) as IssuerListPaymentMethod
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let methods = PaymentMethods(regular: [unsupportedMethod, card], stored: [])
        let sut = try makeSUT(paymentMethods: methods, paymentComponentProvider: checkoutProvider())

        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type), [.scheme])
        XCTAssertEqual(sut.sections.flatMap(\.paymentMethods).map(\.type), [.scheme])
    }

    func test_supportedMethods_withCheckoutBuilder_missingApplePayConfigurationOmitsOnlyApplePay() throws {
        let applePay = try AdyenCoder.decode(applePayDictionary) as ApplePayPaymentMethod
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let methods = PaymentMethods(regular: [applePay, card], stored: [])
        let sut = try makeSUT(paymentMethods: methods, paymentComponentProvider: checkoutProvider())

        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type), [.scheme])
    }

    func test_visibleStoredPaymentMethods_excludesMethodsUnsupportedInThePaymentList() throws {
        var unsupportedStoredCard = storedCreditCardDictionary
        unsupportedStoredCard["id"] = "unsupported-stored-payment-method"
        unsupportedStoredCard["supportedShopperInteractions"] = ["ContAuth"]
        let methods = try AdyenCoder.decode([
            "storedPaymentMethods": [storedCreditCardDictionary, unsupportedStoredCard],
            "paymentMethods": []
        ]) as PaymentMethods
        let sut = makeSUT(paymentMethods: methods, paymentComponentBuilder: genericBuilder)

        XCTAssertEqual(sut.visibleStoredPaymentMethods.map(\.identifier), [methods.stored[0].identifier])
        XCTAssertEqual(sut.supportedStoredPaymentMethods.count, 1)
        XCTAssertEqual(sut.sections.first?.paymentMethods.count, 1)
    }

    func test_sections_areOrderedPaidStoredRegularAndOmitEmptySections() throws {
        let paid = OrderPaymentMethod(
            lastFour: "1234",
            type: .other("paid"),
            transactionLimit: Amount(value: 100, currencyCode: "EUR"),
            amount: Amount(value: 100, currencyCode: "EUR")
        )
        let stored = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let regular = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        var methods = PaymentMethods(regular: [regular], stored: [stored])
        methods.paid = [paid]

        let sut = makeSUT(paymentMethods: methods, paymentComponentBuilder: genericBuilder)

        XCTAssertEqual(sut.sections.map(\.kind), [.paid, .stored, .regular])
        XCTAssertEqual(sut.sections.flatMap(\.paymentMethods).map(\.name), [paid.name, stored.name, regular.name])

        sut.update(paymentMethods: PaymentMethods(regular: [regular], stored: []))

        XCTAssertEqual(sut.sections.map(\.kind), [.regular])
        XCTAssertNil(sut.sections[0].header)
    }

    func test_buildComponent_forDisplayedMethod_createsFreshComponent() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            paymentComponentBuilder: genericBuilder
        )
        let displayed = try XCTUnwrap(sut.sections.first?.paymentMethods.first)

        let selected = try XCTUnwrap(sut.buildComponent(for: displayed))
        let reopened = try XCTUnwrap(sut.buildComponent(for: displayed))

        XCTAssertFalse(selected === reopened)
    }

    func test_buildComponent_forStoredMethod_createsFreshComponentWithMatchingIdentifier() throws {
        var firstDictionary = storedCreditCardDictionary
        firstDictionary["id"] = "first"
        var secondDictionary = storedCreditCardDictionary
        secondDictionary["id"] = "second"
        let methods = try AdyenCoder.decode([
            "storedPaymentMethods": [firstDictionary, secondDictionary],
            "paymentMethods": []
        ]) as PaymentMethods
        let sut = makeSUT(paymentMethods: methods, paymentComponentBuilder: genericBuilder)

        let selected = try XCTUnwrap(sut.buildComponent(for: methods.stored[1]))
        let reopened = try XCTUnwrap(sut.buildComponent(for: methods.stored[1]))

        XCTAssertFalse(selected === reopened)
        XCTAssertEqual((selected.paymentMethod as? any StoredPaymentMethod)?.identifier, "second")
    }

    func test_updatePaymentMethods_recomputesSupportedMethodsAndSections() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let blik = try AdyenCoder.decode(blik) as BLIKPaymentMethod
        var buildCount = 0
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            paymentComponentBuilder: { paymentMethod in
                buildCount += 1
                return self.genericComponent(for: paymentMethod)
            }
        )
        _ = sut.supportedRegularPaymentMethods

        sut.update(paymentMethods: PaymentMethods(regular: [blik], stored: []))

        XCTAssertEqual(buildCount, 0)
        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type), [.blik])
        XCTAssertEqual(sut.sections.flatMap(\.paymentMethods).map(\.type), [.blik])
        XCTAssertNil(sut.buildComponent(for: card))
    }

    func test_removeStoredPaymentMethod_updatesSupportedMethodsAndSection() throws {
        var firstDictionary = storedCreditCardDictionary
        firstDictionary["id"] = "first"
        var secondDictionary = storedCreditCardDictionary
        secondDictionary["id"] = "second"
        let methods = try AdyenCoder.decode([
            "storedPaymentMethods": [firstDictionary, secondDictionary],
            "paymentMethods": []
        ]) as PaymentMethods
        let sut = makeSUT(paymentMethods: methods, paymentComponentBuilder: genericBuilder)

        sut.removeStoredPaymentMethod(withIdentifier: "first")

        XCTAssertEqual(sut.paymentMethods.stored.map(\.identifier), ["second"])
        XCTAssertEqual(sut.visibleStoredPaymentMethods.map(\.identifier), ["second"])
        XCTAssertEqual(
            sut.sections.first { $0.kind == .stored }?.paymentMethods.compactMap {
                ($0 as? any StoredPaymentMethod)?.identifier
            },
            ["second"]
        )
    }

    func test_buildComponent_withOrder_preservesOrderOnSupportedComponent() throws {
        let order = PartialPaymentOrder(pspReference: "psp-reference", orderData: "order-data")
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            order: order,
            paymentComponentBuilder: genericBuilder
        )

        _ = sut.supportedRegularPaymentMethods
        XCTAssertEqual(sut.buildComponent(for: card)?.order, order)
    }

    func test_supportedRegularPaymentMethods_withVoucherAndQRCodeMethods_shouldIncludeThem() throws {
        let methods = try AdyenCoder.decode([
            "paymentMethods": [oxxo, ["type": "pix", "name": "PIX"]]
        ]) as PaymentMethods
        var assertionCount = 0
        AdyenAssertion.listener = { _ in assertionCount += 1 }
        let sut = makeSUT(
            paymentMethods: methods,
            paymentComponentBuilder: genericBuilder
        )

        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type.rawValue), ["oxxo", "pix"])
        XCTAssertEqual(sut.sections.count, 1)
        XCTAssertEqual(assertionCount, 0)
    }

    func test_componentConfigurationResolvedByInjectedBuilder_isNotOverwritten() throws {
        let checkoutProvider = LocalizationProviderMock()
        let dropInProvider = LocalizationProviderMock()
        let customTheme = CheckoutTheme(colors: CheckoutColors(primary: .yellow))
        var checkoutConfiguration = makeCheckoutConfiguration()
            .localizationProvider(checkoutProvider)
            .theme(customTheme)
        checkoutConfiguration.configurations[.payment(.scheme)] = CardConfiguration()
        configuration.localizationProvider = dropInProvider
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        var buildCount = 0
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            paymentComponentBuilder: { paymentMethod in
                buildCount += 1
                return try CheckoutComponentBuilder.build(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: checkoutConfiguration,
                    context: self.context
                )
            }
        )

        _ = sut.supportedRegularPaymentMethods
        let component = try XCTUnwrap(sut.buildComponent(for: card) as? CardComponent)

        XCTAssertEqual(buildCount, 1)
        XCTAssertTrue(component.configuration.localizationParameters?.provider as AnyObject === checkoutProvider)
        XCTAssertEqual(component.configuration.theme.colors.primary, .yellow)
    }

    // MARK: - Availability

    func test_sectionsAndHasSupportedPaymentMethods_shouldCheckAvailabilityWithoutBuildingComponents() throws {
        let methods = try supportedPaymentMethods()
        var availabilityCount = 0
        var buildCount = 0
        let sut = makeSUT(
            paymentMethods: methods,
            isAvailable: { _ in
                availabilityCount += 1
                return true
            },
            paymentComponentBuilder: { paymentMethod in
                buildCount += 1
                return self.genericComponent(for: paymentMethod)
            }
        )

        XCTAssertTrue(sut.hasSupportedPaymentMethods)
        _ = sut.sections

        XCTAssertEqual(availabilityCount, methods.regular.count + methods.stored.count)
        XCTAssertEqual(buildCount, 0)
    }

    func test_supportedRegularPaymentMethods_whenProviderReportsUnavailable_shouldOmitOnlyThatMethod() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let blik = try AdyenCoder.decode(blik) as BLIKPaymentMethod
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card, blik], stored: []),
            isAvailable: { $0.type != .blik },
            paymentComponentBuilder: genericBuilder
        )

        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type), [.scheme])
        XCTAssertNil(sut.buildComponent(for: blik))
    }

    func test_supportedStoredPaymentMethods_withoutShopperPresent_shouldBeExcludedWithoutCheckingAvailability() throws {
        var unsupportedStoredCard = storedCreditCardDictionary
        unsupportedStoredCard["supportedShopperInteractions"] = ["ContAuth"]
        let methods = try AdyenCoder.decode([
            "storedPaymentMethods": [unsupportedStoredCard],
            "paymentMethods": []
        ]) as PaymentMethods
        var availabilityCount = 0
        let sut = makeSUT(
            paymentMethods: methods,
            isAvailable: { _ in
                availabilityCount += 1
                return true
            },
            paymentComponentBuilder: genericBuilder
        )

        XCTAssertTrue(sut.supportedStoredPaymentMethods.isEmpty)
        XCTAssertEqual(availabilityCount, 0)
    }

    // MARK: - Selection

    func test_buildComponent_forRetainedMethod_shouldBuildOnceWithoutRecheckingAvailability() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        var availabilityCount = 0
        var buildCount = 0
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            isAvailable: { _ in
                availabilityCount += 1
                return true
            },
            paymentComponentBuilder: { paymentMethod in
                buildCount += 1
                return self.genericComponent(for: paymentMethod)
            }
        )
        _ = sut.supportedRegularPaymentMethods
        availabilityCount = 0

        XCTAssertNotNil(sut.buildComponent(for: card))
        XCTAssertEqual(buildCount, 1)
        XCTAssertEqual(availabilityCount, 0)
    }

    func test_buildComponent_whenBuildThrows_shouldReturnNilAndKeepRetainedMethods() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            paymentComponentBuilder: { _ in
                throw CheckoutError(code: .paymentMethodFailure, message: "Build failed.")
            }
        )

        XCTAssertNil(sut.buildComponent(for: card))
        XCTAssertEqual(sut.supportedRegularPaymentMethods.map(\.type), [.scheme])
        XCTAssertEqual(sut.sections.flatMap(\.paymentMethods).map(\.type), [.scheme])
    }

    func test_buildComponent_forMethodNotRetained_shouldNotBuild() throws {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let blik = try AdyenCoder.decode(blik) as BLIKPaymentMethod
        var buildCount = 0
        let sut = makeSUT(
            paymentMethods: PaymentMethods(regular: [card], stored: []),
            paymentComponentBuilder: { paymentMethod in
                buildCount += 1
                return self.genericComponent(for: paymentMethod)
            }
        )

        XCTAssertNil(sut.buildComponent(for: blik))
        XCTAssertEqual(buildCount, 0)
    }

    // MARK: - Helpers

    private var genericBuilder: @MainActor (PaymentMethod) throws -> PaymentComponent {
        { paymentMethod in self.genericComponent(for: paymentMethod) }
    }

    private func genericComponent(for paymentMethod: PaymentMethod) -> PaymentComponent {
        GenericPaymentComponent(paymentMethod: paymentMethod, context: context, order: nil)
    }

    private func makeSUT(
        paymentMethods: PaymentMethods,
        order: PartialPaymentOrder? = nil,
        isAvailable: @escaping @MainActor (PaymentMethod) -> Bool = { _ in true },
        paymentComponentBuilder: @escaping @MainActor (PaymentMethod) throws -> PaymentComponent
    ) -> ComponentManager {
        makeSUT(
            paymentMethods: paymentMethods,
            order: order,
            paymentComponentProvider: DropInPaymentComponentProvider(
                isAvailable: isAvailable,
                build: paymentComponentBuilder
            )
        )
    }

    private func makeSUT(
        paymentMethods: PaymentMethods,
        order: PartialPaymentOrder? = nil,
        paymentComponentProvider: DropInPaymentComponentProvider
    ) -> ComponentManager {
        ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: order,
            paymentComponentProvider: paymentComponentProvider
        )
    }

    private func supportedPaymentMethods() throws -> PaymentMethods {
        let card = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let applePay = try AdyenCoder.decode(applePayDictionary) as ApplePayPaymentMethod
        let ach = try AdyenCoder.decode(achDirectDebit) as ACHDirectDebitPaymentMethod
        let blik = try AdyenCoder.decode(blik) as BLIKPaymentMethod
        let generic = try AdyenCoder.decode(["type": "ideal", "name": "iDEAL"]) as GenericPaymentMethod
        let storedCard = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let storedGeneric = try AdyenCoder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
        return PaymentMethods(
            regular: [card, applePay, ach, blik, generic],
            stored: [storedCard, storedGeneric]
        )
    }

    private func checkoutProvider(includingApplePay: Bool = false) throws -> DropInPaymentComponentProvider {
        var configurations: [CheckoutComponentType: CheckoutComponentConfiguration] = [:]
        if includingApplePay {
            configurations[.payment(.applePay)] = try ApplePayConfiguration(
                paymentRequest: Dummy.createTestApplePayPaymentRequest()
            )
        }
        let checkoutConfiguration = makeCheckoutConfiguration(configurations: configurations)
        return DropInPaymentComponentProvider(
            isAvailable: { paymentMethod in
                CheckoutComponentBuilder.isAvailable(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: checkoutConfiguration
                )
            },
            build: { paymentMethod in
                try CheckoutComponentBuilder.build(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: checkoutConfiguration,
                    context: self.context
                )
            }
        )
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
}

private final class LocalizationProviderMock: CheckoutLocalizationProvider {
    func localizedString(_: CheckoutLocalizationKey, locale _: Locale) -> String? {
        nil
    }
}
