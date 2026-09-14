//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import PassKit
import UIKit
import XCTest

@MainActor
final class CheckoutDropInComponentTests: XCTestCase {

    func test_createDropIn_repeatedly_returnsFreshComponents() throws {
        let checkout = makeCheckout(paymentMethods: makePaymentMethods())

        let first = try checkout.createDropIn()
        let second = try checkout.createDropIn()

        XCTAssertFalse(first === second)
        XCTAssertFalse(first.viewController === second.viewController)
    }

    func test_checkoutDeallocation_whileFacadeIsRetained_shouldNotReleaseDropIn() throws {
        let callbackStore = AdvancedCheckoutCallbackStore()
        var core: CheckoutCore? = makeCore(
            paymentMethods: makePaymentMethods(),
            callbackStore: callbackStore
        )
        weak var weakCore = core
        var checkout: AdvancedCheckout? = try AdvancedCheckout(
            core: XCTUnwrap(core),
            callbackStore: callbackStore
        )
        let dropIn = try XCTUnwrap(checkout).createDropIn()

        checkout = nil
        core = nil

        XCTAssertNil(weakCore)
        XCTAssertTrue(dropIn.viewController is UINavigationController)
    }

    func test_facadeDeallocation_shouldReleaseDropIn() throws {
        weak var weakDropIn: DropInComponent?
        var dropIn: CheckoutDropInComponent? = try makeCheckout(paymentMethods: makePaymentMethods()).createDropIn()
        weakDropIn = dropIn?.dropInComponent

        dropIn = nil

        XCTAssertNil(weakDropIn)
    }

    func test_createDropIn_withoutPaymentMethods_shouldThrowPaymentMethodFailure() {
        let checkout = makeCheckout(paymentMethods: nil)

        assertPaymentMethodFailure(when: checkout.createDropIn)
    }

    func test_createDropIn_withoutSupportedPaymentMethods_shouldThrowPaymentMethodFailure() {
        let unsupportedMethod = PaymentMethodMock(type: .payPal, name: "Unsupported")
        let checkout = makeCheckout(paymentMethods: PaymentMethods(regular: [unsupportedMethod], stored: []))

        assertPaymentMethodFailure(when: checkout.createDropIn)
    }

    func test_createDropIn_withHiddenStoredMethodAndPreselectionDisabled_shouldThrowPaymentMethodFailure() throws {
        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let configuration = makeConfiguration(
            dropInConfiguration: DropInConfiguration()
                .hideStoredPaymentMethods(true)
                .startWithLastStoredPaymentMethod(false)
        )
        let checkout = makeCheckout(
            paymentMethods: PaymentMethods(regular: [], stored: [storedPaymentMethod]),
            configuration: configuration
        )

        assertPaymentMethodFailure(when: checkout.createDropIn)
    }

    func test_createDropIn_withHiddenStoredMethodAndPreselectionEnabled_shouldSucceed() throws {
        let storedPaymentMethod = try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
        let configuration = makeConfiguration(
            dropInConfiguration: DropInConfiguration()
                .hideStoredPaymentMethods(true)
                .startWithLastStoredPaymentMethod(true)
        )
        let checkout = makeCheckout(
            paymentMethods: PaymentMethods(regular: [], stored: [storedPaymentMethod]),
            configuration: configuration
        )

        let dropIn = try checkout.createDropIn()
        let navigationController = try XCTUnwrap(dropIn.viewController as? UINavigationController)
        navigationController.topViewController?.loadViewIfNeeded()
        let otherPaymentMethodsButton: FormButton? = navigationController.view.findView(by: "secondaryButton")

        XCTAssertEqual(otherPaymentMethodsButton?.isHidden, true)
    }

    func test_createDropIn_shouldApplyCheckoutThemeToPresentedList() throws {
        let backgroundColor = UIColor.magenta
        let configuration = makeConfiguration()
            .theme(CheckoutTheme(colors: CheckoutColors(background: backgroundColor)))
        let checkout = makeCheckout(
            paymentMethods: makePaymentMethods(regular: [creditCardDictionary, blik]),
            configuration: configuration
        )

        let dropIn = try checkout.createDropIn()
        let navigationController = try XCTUnwrap(dropIn.viewController as? UINavigationController)
        let listViewController = try XCTUnwrap(navigationController.topViewController as? PaymentMethodListViewController)
        listViewController.loadViewIfNeeded()

        XCTAssertEqual(listViewController.view.backgroundColor, backgroundColor)
    }

    func test_createDropIn_withApplePay_shouldPresentApplePayFromHeaderButton() throws {
        let configuration = try makeConfiguration(configurations: [
            .payment(.applePay): ApplePayConfiguration(
                paymentRequest: Dummy.createTestApplePayPaymentRequest()
            )
        ])
        let checkout = makeCheckout(
            paymentMethods: makePaymentMethods(regular: [applePayDictionary, creditCardDictionary]),
            configuration: configuration
        )
        let dropIn = try checkout.createDropIn()
        let navigationController = try XCTUnwrap(dropIn.viewController as? UINavigationController)
        presentOnRoot(navigationController)
        navigationController.topViewController?.loadViewIfNeeded()
        let applePayButton = try XCTUnwrap(navigationController.view.firstSubview(of: PKPaymentButton.self))

        applePayButton.sendActions(for: .touchUpInside)
        wait(for: .aMoment)

        XCTAssertTrue(navigationController.presentedViewController is PKPaymentAuthorizationViewController)
    }

    private func assertPaymentMethodFailure(
        when operation: () throws -> CheckoutDropInComponent,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try operation(), file: file, line: line) { error in
            XCTAssertEqual((error as? CheckoutError)?.code, .paymentMethodFailure, file: file, line: line)
        }
    }

    private func makeCheckout(
        paymentMethods: PaymentMethods?,
        configuration: CheckoutConfiguration? = nil
    ) -> AdvancedCheckout {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let core = makeCore(
            paymentMethods: paymentMethods,
            configuration: configuration,
            callbackStore: callbackStore
        )
        return AdvancedCheckout(core: core, callbackStore: callbackStore)
    }

    private func makeCore(
        paymentMethods: PaymentMethods?,
        configuration: CheckoutConfiguration? = nil,
        callbackStore: AdvancedCheckoutCallbackStore
    ) -> CheckoutCore {
        let configuration = configuration ?? makeConfiguration()
        return CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }

    private func makeConfiguration(
        configurations: [CheckoutComponentType: CheckoutComponentConfiguration] = [:],
        dropInConfiguration: DropInConfiguration = .init()
    ) -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init(),
            configurations: configurations,
            dropInConfiguration: dropInConfiguration
        )
    }

    private func makePaymentMethods(
        regular dictionaries: [[String: Any]] = [creditCardDictionary, blik]
    ) -> PaymentMethods {
        let regular: [PaymentMethod] = dictionaries.map { dictionary in
            switch dictionary["type"] as? String {
            case PaymentMethodType.scheme.rawValue:
                return try! AdyenCoder.decode(dictionary) as CardPaymentMethod
            case PaymentMethodType.blik.rawValue:
                return try! AdyenCoder.decode(dictionary) as BLIKPaymentMethod
            case PaymentMethodType.applePay.rawValue:
                return try! AdyenCoder.decode(dictionary) as ApplePayPaymentMethod
            default:
                fatalError("Unsupported test payment method dictionary")
            }
        }
        return PaymentMethods(regular: regular, stored: [])
    }
}

private extension UIView {

    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }
        return subviews.lazy.compactMap { $0.firstSubview(of: type) }.first
    }
}
