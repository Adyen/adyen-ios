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
@testable import AdyenSession
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

@MainActor
final class CheckoutCoreDropInTests: XCTestCase {

    private var configuration: CheckoutConfiguration!
    private var paymentMethods: PaymentMethods!

    override func setUp() {
        super.setUp()
        configuration = CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
        paymentMethods = try! AdyenCoder.decode([
            "storedPaymentMethods": [storedCreditCardDictionary],
            "paymentMethods": [creditCardDictionary, blik]
        ]) as PaymentMethods
    }

    func test_createDropIn_withoutPaymentMethods_shouldReturnNil() {
        let sut = makeAdvancedCheckoutCore(paymentMethods: nil)

        XCTAssertNil(sut.createDropIn())
    }

    func test_createDropIn_withAdvancedCheckout_shouldAssembleDropInAndSetDelegate() throws {
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertTrue(dropIn.delegate === sut)
        XCTAssertNil(dropIn.storedPaymentMethodManagementCapability)
        XCTAssertTrue(dropIn.viewController is UINavigationController)
    }

    func test_createDropIn_withSessionCheckout_shouldAssembleDropInViewController() throws {
        let sut = makeSessionCheckoutCore(session: makeSessionMock())

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertTrue(dropIn.delegate === sut)
        XCTAssertTrue(dropIn.viewController is UINavigationController)
    }

    func test_createDropIn_shouldResolveCheckoutThemeAndLocalizationProvider() throws {
        let provider = DropInLocalizationProviderMock()
        let theme = CheckoutTheme(colors: CheckoutColors(primary: .yellow))
        configuration = configuration
            .localizationProvider(provider)
            .theme(theme)
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertEqual(dropIn.configuration.theme.colors.primary, .yellow)
        XCTAssertTrue(dropIn.configuration.localizationProvider as AnyObject === provider)
    }

    func test_createDropIn_withAdvancedRemovalEnabled_shouldKeepManagementUnavailable() throws {
        configuration.dropInConfiguration = DropInConfiguration()
            .allowRemovingStoredPaymentMethods(true)
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertNil(dropIn.storedPaymentMethodManagementCapability)
    }

    func test_createDropIn_withSessionRemovalDisabled_shouldKeepManagementUnavailable() throws {
        let session = makeSessionMock()
        session.showRemovePaymentMethodButton = false
        let sut = makeSessionCheckoutCore(session: session)

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertNil(dropIn.storedPaymentMethodManagementCapability)
    }

    func test_createDropIn_withSessionRemovalEnabled_shouldProvideManagementCapability() throws {
        let session = makeSessionMock()
        session.showRemovePaymentMethodButton = true
        let sut = makeSessionCheckoutCore(session: session)

        let dropIn = try XCTUnwrap(sut.createDropIn())

        XCTAssertNotNil(dropIn.storedPaymentMethodManagementCapability)
    }

    func test_sessionManagementCapability_whenRemovingStoredMethod_shouldCallSession() async throws {
        let session = makeSessionMock()
        session.showRemovePaymentMethodButton = true
        let sut = makeSessionCheckoutCore(session: session)
        let dropIn = try XCTUnwrap(sut.createDropIn())
        let capability = try XCTUnwrap(dropIn.storedPaymentMethodManagementCapability)
        let storedPaymentMethod = try XCTUnwrap(paymentMethods.stored.first)

        try await capability.remove(storedPaymentMethod)

        XCTAssertTrue(session.disableStoredPaymentMethodCalled)
        XCTAssertEqual(session.disabledStoredPaymentMethod?.identifier, storedPaymentMethod.identifier)
    }

    func test_dropInSubmit_whenAdvancedHandlerReturnsAction_shouldRouteActionBackToDropIn() async throws {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let awaitAction = AwaitAction(paymentData: "payment-data", paymentMethodType: .blik)
        let action = Action.await(awaitAction)
        callbackStore.onSubmit = { _ in .action(action) }
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore, paymentMethods: paymentMethods)
        let dropIn = ActionHandlingDropInMock()
        let handledAction = expectation(description: "Drop-in handled action")
        dropIn.onHandle = { receivedAction in
            guard case let .await(receivedAwaitAction) = receivedAction else {
                return XCTFail("Expected an await action.")
            }
            XCTAssertEqual(receivedAwaitAction.paymentData, awaitAction.paymentData)
            handledAction.fulfill()
        }
        let paymentMethod = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: paymentMethod, blikCode: "code"),
            order: nil
        )

        sut.didSubmit(data, from: component, in: dropIn)

        await fulfillment(of: [handledAction], timeout: 1)
        XCTAssertTrue(sut.pendingPaymentComponent === component)
    }

    func test_dropInAdditionalDetails_shouldReachAdvancedHandlerAndCompleteOnce() async {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let detailsHandled = expectation(description: "Additional details handled")
        let completed = expectation(description: "Checkout completed")
        var completionCount = 0
        callbackStore.onAdditionalDetails = { data in
            XCTAssertEqual(data.paymentData, "payment-data")
            detailsHandled.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        callbackStore.onComplete = { _ in
            completionCount += 1
            completed.fulfill()
        }
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore, paymentMethods: paymentMethods)
        let data = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "payment-data"
        )

        sut.didProvide(data, from: ActionComponentMock(), in: ActionHandlingDropInMock())

        await fulfillment(of: [detailsHandled, completed], timeout: 1)
        XCTAssertEqual(completionCount, 1)
    }

    func test_dropInPaymentFailure_shouldReachFailureHandlerOnce() {
        let callbackStore = AdvancedCheckoutCallbackStore()
        var failureCount = 0
        callbackStore.onFailure = { _ in failureCount += 1 }
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore, paymentMethods: paymentMethods)
        let paymentMethod = paymentMethods.regular[0]

        sut.didFail(
            with: DropInTestError(),
            from: PaymentComponentMock(paymentMethod: paymentMethod),
            in: ActionHandlingDropInMock()
        )

        XCTAssertEqual(failureCount, 1)
    }

    private func makeAdvancedCheckoutCore(
        callbackStore: AdvancedCheckoutCallbackStore = AdvancedCheckoutCallbackStore(),
        paymentMethods: PaymentMethods?
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }

    private func makeSessionCheckoutCore(session: AdyenSessionMock) -> CheckoutCore {
        let callbackStore = SessionCheckoutCallbackStore()
        return CheckoutCore(
            configuration: configuration,
            session: session,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: BeforeSubmitCallbackHandler(
                handler: SessionCallbackHandler(session: session),
                session: session,
                callbackStore: callbackStore
            )
        )
    }

    private func makeSessionMock() -> AdyenSessionMock {
        AdyenSessionMock(state: .init(
            data: "session-data",
            identifier: "session-id",
            countryCode: "US",
            shopperLocale: "en_US",
            amount: Dummy.amount,
            paymentMethods: paymentMethods,
            responseConfiguration: .init(installmentOptions: nil, enableStoreDetails: true)
        ))
    }
}

@MainActor
private final class ActionHandlingDropInMock: @preconcurrency AnyDropInComponent, ActionHandlingComponent {

    let context = Dummy.context
    let viewController = UIViewController()
    weak var delegate: DropInComponentDelegate?
    var onHandle: ((Action) -> Void)?

    func handle(_ action: Action) {
        onHandle?(action)
    }

    func reload(with order: PartialPaymentOrder, _ paymentMethods: PaymentMethods) throws {}
}

@MainActor
private final class ActionComponentMock: ActionComponent {
    let context = Dummy.context
    weak var delegate: ActionComponentDelegate?
}

private final class DropInLocalizationProviderMock: CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        nil
    }
}

private struct DropInTestError: Error {}
