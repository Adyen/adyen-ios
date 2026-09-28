//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenTwint
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
final class CheckoutComponentBuilderAvailabilityTests: XCTestCase {

    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
        context = Dummy.context
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Dispatch parity

    /// Every regular payment method family that `build` supports must also be dispatched by `isAvailable`.
    /// Add new families to this list when extending either switch.
    func test_isAvailable_withEachSupportedRegularPaymentMethod_shouldMatchBuildResult() throws {
        let configuration = try makeCheckoutConfiguration(
            configurations: [.payment(.applePay): makeApplePayConfiguration()]
        )
        let paymentMethods: [PaymentMethod] = try [
            XCTUnwrap(AdyenCoder.decode(["type": "blik", "name": "BLIK"]) as BLIKPaymentMethod),
            XCTUnwrap(AdyenCoder.decode(["type": "ach", "name": "ACH Direct Debit"]) as ACHDirectDebitPaymentMethod),
            ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: ["visa", "mc"]),
            GenericPaymentMethod(type: .other("paypal"), name: "PayPal"),
            XCTUnwrap(AdyenCoder.decode(["type": "scheme", "name": "Cards", "brands": ["mc", "visa"]]) as CardPaymentMethod),
            TwintPaymentMethod(type: .twint, name: "Twint")
        ]

        for paymentMethod in paymentMethods {
            let isAvailable = CheckoutComponentBuilder.isAvailable(
                forAnyPaymentMethod: paymentMethod,
                configuration: configuration
            )
            let builtComponent = try? CheckoutComponentBuilder.build(
                forAnyPaymentMethod: paymentMethod,
                configuration: configuration,
                context: context
            )

            XCTAssertTrue(isAvailable, "\(paymentMethod.type.rawValue) should be available")
            XCTAssertNotNil(builtComponent, "\(paymentMethod.type.rawValue) should be buildable")
        }
    }

    func test_isAvailable_withUnsupportedPaymentMethod_shouldReturnFalse() {
        let paymentMethod = UnsupportedPaymentMethod()
        let configuration = makeCheckoutConfiguration()

        XCTAssertFalse(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: paymentMethod, configuration: configuration))
        XCTAssertThrowsError(
            try CheckoutComponentBuilder.build(forAnyPaymentMethod: paymentMethod, configuration: configuration, context: context)
        )
    }

    // MARK: - Stored payment methods

    func test_isAvailable_withStoredPaymentMethods_shouldReturnTrue() throws {
        let storedCard = try AdyenCoder.decode([
            "type": "scheme",
            "id": "9314881977134903",
            "name": "VISA",
            "brand": "visa",
            "lastFour": "1111",
            "expiryMonth": "08",
            "expiryYear": "2018",
            "holderName": "test",
            "supportedShopperInteractions": ["Ecommerce", "ContAuth"]
        ]) as StoredCardPaymentMethod
        let storedPayPal = try AdyenCoder.decode([
            "type": "paypal",
            "id": "9314881977134904",
            "name": "PayPal",
            "shopperEmail": "example@shopper.com",
            "supportedShopperInteractions": ["Ecommerce", "ContAuth"]
        ]) as StoredPayPalPaymentMethod
        let configuration = makeCheckoutConfiguration()

        XCTAssertTrue(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: storedCard, configuration: configuration))
        XCTAssertTrue(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: storedPayPal, configuration: configuration))
    }

    // MARK: - Apple Pay

    func test_isAvailable_withApplePayAndNoConfiguration_shouldOnlyOmitApplePay() throws {
        let configuration = makeCheckoutConfiguration()
        let applePay = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: ["visa", "mc"])
        let card = try AdyenCoder.decode(["type": "scheme", "name": "Cards", "brands": ["mc", "visa"]]) as CardPaymentMethod

        XCTAssertFalse(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: applePay, configuration: configuration))
        XCTAssertTrue(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: card, configuration: configuration))
    }

    func test_isAvailable_withApplePayUnableToPay_shouldReturnFalse() throws {
        let configuration = try makeCheckoutConfiguration(
            configurations: [.payment(.applePay): makeApplePayConfiguration().allowOnboarding(false)]
        )
        let applePay = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: [])

        XCTAssertFalse(CheckoutComponentBuilder.isAvailable(forAnyPaymentMethod: applePay, configuration: configuration))
    }

    // MARK: - Configuration resolution

    func test_isAvailable_withMerchantConfiguration_shouldPassResolvedConfigurationToFactory() throws {
        let paymentMethod = try AdyenCoder.decode(["type": "blik", "name": "BLIK"]) as BLIKPaymentMethod
        let localizationParameters = LocalizationParameters(enforcedLocale: "it-IT")
        var blikConfiguration = BLIKComponentConfiguration()
        blikConfiguration.showsSubmitButton = true
        blikConfiguration.localizationParameters = localizationParameters
        var configuration = makeCheckoutConfiguration(configurations: [.payment(.blik): blikConfiguration])
        configuration.showsSubmitButton = false
        configuration.theme = CheckoutTheme(colors: CheckoutColors(primary: .yellow))
        let factory = AvailabilitySpyFactory()

        let isAvailable = CheckoutComponentBuilder.isAvailable(
            using: factory,
            paymentMethod: paymentMethod,
            configuration: configuration
        )

        XCTAssertTrue(isAvailable)
        XCTAssertEqual(factory.receivedPaymentMethods.map(\.type), [.blik])
        let receivedConfiguration = try XCTUnwrap(factory.receivedConfigurations.first)
        XCTAssertFalse(receivedConfiguration.showsSubmitButton)
        XCTAssertEqual(receivedConfiguration.theme.colors.primary, .yellow)
        XCTAssertEqual(receivedConfiguration.localizationParameters, localizationParameters)
    }

    func test_isAvailable_withoutMerchantConfiguration_shouldPassFactoryDefaultToFactory() throws {
        let paymentMethod = try AdyenCoder.decode(["type": "blik", "name": "BLIK"]) as BLIKPaymentMethod
        let factory = AvailabilitySpyFactory()

        _ = CheckoutComponentBuilder.isAvailable(
            using: factory,
            paymentMethod: paymentMethod,
            configuration: makeCheckoutConfiguration()
        )

        XCTAssertEqual(factory.defaultConfigurationCallsCount, 1)
        XCTAssertEqual(factory.receivedConfigurations.count, 1)
    }

    func test_isAvailable_whenFactoryReportsUnavailable_shouldReturnFalse() throws {
        let paymentMethod = try AdyenCoder.decode(["type": "blik", "name": "BLIK"]) as BLIKPaymentMethod
        let factory = AvailabilitySpyFactory(isAvailable: false)

        XCTAssertFalse(
            CheckoutComponentBuilder.isAvailable(
                using: factory,
                paymentMethod: paymentMethod,
                configuration: makeCheckoutConfiguration()
            )
        )
    }

    // MARK: - Helpers

    private func makeApplePayConfiguration() throws -> ApplePayConfiguration {
        try ApplePayConfiguration(paymentRequest: Dummy.createTestApplePayPaymentRequest())
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

private struct UnsupportedPaymentMethod: PaymentMethod {
    var type: PaymentMethodType {
        .other("unsupported")
    }

    var name: String {
        "Unsupported"
    }

    init() {}
    init(from decoder: Decoder) throws {}
    func encode(to encoder: Encoder) throws {}
}

@MainActor
private final class AvailabilitySpyFactory: PaymentComponentFactory {
    typealias Configuration = BLIKComponentConfiguration
    typealias Method = BLIKPaymentMethod
    typealias Component = BLIKComponent

    private let isAvailableResult: Bool
    private(set) var receivedPaymentMethods: [BLIKPaymentMethod] = []
    private(set) var receivedConfigurations: [BLIKComponentConfiguration] = []
    private(set) var defaultConfigurationCallsCount = 0

    init(isAvailable: Bool = true) {
        self.isAvailableResult = isAvailable
    }

    func isAvailable(for paymentMethod: BLIKPaymentMethod, configuration: BLIKComponentConfiguration) -> Bool {
        receivedPaymentMethods.append(paymentMethod)
        receivedConfigurations.append(configuration)
        return isAvailableResult
    }

    func create(
        with paymentMethod: BLIKPaymentMethod,
        context: AdyenContext,
        configuration: BLIKComponentConfiguration
    ) -> BLIKComponent {
        BLIKComponentFactory().create(with: paymentMethod, context: context, configuration: configuration)
    }

    func defaultConfiguration() -> BLIKComponentConfiguration {
        defaultConfigurationCallsCount += 1
        return BLIKComponentConfiguration()
    }
}
