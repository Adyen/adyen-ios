//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import Contacts
import PassKit
import XCTest

@MainActor
class ApplePayComponentTest: XCTestCase {

    var mockDelegate: PaymentComponentDelegateMock!
    var sut: ApplePayComponent!
    var controllerMock: ApplePayAuthorizationControllerMock!
    var makeControllerCallsCount = 0
    /// Passed to the handler's PassKit delegate methods. The handler itself only talks to `controllerMock`.
    lazy var passKitController = PKPaymentAuthorizationController(paymentRequest: Dummy.createTestApplePayPaymentRequest())
    lazy var amount = Amount(value: 2, currencyCode: "USD")
    lazy var countryCode = getRandomCountryCode()
    let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: ["visa", "amex", "mc"])

    /// The PassKit delegate of the sheet on screen.
    private var handler: ApplePayAuthorizationHandler! {
        sut.authorizationHandler
    }

    private var emptyVC: UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }

    override func setUp() {
        do {
            let configuration = try ApplePayConfiguration(
                paymentRequest: Dummy.createTestApplePayPaymentRequest()
            )
            controllerMock = ApplePayAuthorizationControllerMock()
            sut = try makeComponent(configuration: configuration)
        } catch {
            XCTFail("setUp failed to create ApplePayComponent: \(error)")
        }
        mockDelegate = PaymentComponentDelegateMock()
    }

    override func tearDown() {
        // The sheet only ends when PassKit reports that it finished.
        sut?.delegate = nil
        sut?.authorizationHandler?.paymentAuthorizationControllerDidFinish(passKitController)
        sut = nil
        mockDelegate = nil
        controllerMock = nil
        makeControllerCallsCount = 0
        
        UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.dismiss(animated: false)
        setupRootViewController(emptyVC)
    }

    // MARK: - requiresUserInteraction

    func testRequiresUserInteractionIsTrue() {
        XCTAssertTrue(sut.requiresUserInteraction)
    }

    // MARK: - Configuration Validation Tests

    func testConfiguration_givenEmptyMerchantIdentifier_shouldThrowEmptyMerchantIdentifier() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = ""
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: 10.0)]
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .emptyMerchantIdentifier)
        }
    }

    func testConfiguration_givenInvalidCountryCode_shouldThrowInvalidCountryCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = "INVALID"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: 10.0)]
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidCountryCode)
        }
    }

    func testConfiguration_givenInvalidCurrencyCode_shouldThrowInvalidCurrencyCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = "US"
        request.currencyCode = "INVALID"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: 10.0)]
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidCurrencyCode)
        }
    }

    func testConfiguration_givenEmptySummaryItems_shouldThrowEmptySummaryItems() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = []
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .emptySummaryItems)
        }
    }

    func testConfiguration_givenNegativeGrandTotal_shouldThrowNegativeGrandTotal() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: -1.0))]
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .negativeGrandTotal)
        }
    }

    func testConfiguration_givenNaNSummaryItem_shouldThrowInvalidSummaryItem() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Item", amount: NSDecimalNumber.notANumber),
            PKPaymentSummaryItem(label: "Total", amount: 10.0)
        ]
        request.merchantCapabilities = .capability3DS

        XCTAssertThrowsError(
            try ApplePayConfiguration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidSummaryItem)
        }
    }

    func testConfiguration_givenValidRequest_shouldSucceed() throws {
        let request = Dummy.createTestApplePayPaymentRequest()

        let config = try ApplePayConfiguration(paymentRequest: request)
            .allowOnboarding(false)

        XCTAssertEqual(config.paymentRequest.merchantIdentifier, request.merchantIdentifier)
        XCTAssertFalse(config.allowOnboarding)
    }

    func testConfiguration_givenNoButtonAppearance_shouldUseDefaultButtonAppearance() throws {
        let config = try ApplePayConfiguration(paymentRequest: Dummy.createTestApplePayPaymentRequest())

        XCTAssertEqual(config.buttonAppearance.buttonType, .plain)
        XCTAssertEqual(config.buttonAppearance.buttonStyle, .automatic)
        XCTAssertNil(config.buttonAppearance.cornerRadius)
    }

    func testConfiguration_givenButtonAppearance_shouldReturnCopyWithButtonAppearance() throws {
        let original = try ApplePayConfiguration(paymentRequest: Dummy.createTestApplePayPaymentRequest())

        let configured = original.buttonAppearance(
            ApplePayButtonAppearance(buttonType: .buy, buttonStyle: .black, cornerRadius: 8)
        )

        XCTAssertEqual(configured.buttonAppearance.buttonType, .buy)
        XCTAssertEqual(configured.buttonAppearance.buttonStyle, .black)
        XCTAssertEqual(configured.buttonAppearance.cornerRadius, 8)
        XCTAssertEqual(original.buttonAppearance.buttonType, .plain)
        XCTAssertEqual(original.buttonAppearance.buttonStyle, .automatic)
        XCTAssertNil(original.buttonAppearance.cornerRadius)
    }

    // MARK: - Component Tests

    func testApplePay_givenBrandsIsEmpty_shouldThrowUserCannotMakePayment() throws {
        // Given
        let brands: [String]? = []
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: brands)
        let configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        .allowOnboarding(false)

        // When / Then
        XCTAssertThrowsError(
            try ApplePayComponent(
                paymentMethod: paymentMethod,
                context: Dummy.context,
                configuration: configuration
            )
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .userCannotMakePayment)
        }
    }

    // MARK: - View Controller

    func test_viewController_shouldBeButtonScreenAndReused() {
        let viewController = sut.viewController

        XCTAssertTrue(viewController is ApplePayButtonViewController)
        XCTAssertTrue(sut.viewController === viewController)
    }

    func test_viewDidLoad_shouldNotSendRenderedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        sut = try makeComponent(configuration: makeConfiguration(), context: context)
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1, "The setup request is sent from init")

        // When
        sut.viewController.loadViewIfNeeded()

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertTrue(analyticsProviderMock.infos.isEmpty)
    }

    func test_submit_whenSheetOpens_shouldSendRenderedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        sut = try makeComponent(configuration: makeConfiguration(), context: context)

        // When
        submit()

        // Then
        wait(until: { !analyticsProviderMock.infos.isEmpty }, timeout: 5, retryInterval: .milliseconds(10))
        XCTAssertEqual(analyticsProviderMock.infos.map(\.type), [.rendered])
    }

    func test_submit_whenSheetCannotBePresented_shouldNotSendRenderedEvent() async throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        sut = try makeComponent(configuration: makeConfiguration(), context: context)
        controllerMock.presentResult = false
        let didFail = expectation(description: "didFail called")
        mockDelegate.onDidFail = { _, _ in didFail.fulfill() }

        // When
        submit()

        // Then
        await fulfillment(of: [didFail], timeout: 5)
        XCTAssertTrue(analyticsProviderMock.infos.isEmpty)
    }

    func test_buttonTap_shouldPresentSheet() throws {
        let viewController = try XCTUnwrap(sut.viewController as? ApplePayButtonViewController)
        viewController.loadViewIfNeeded()

        viewController.paymentButton.sendActions(for: .touchUpInside)

        XCTAssertNotNil(sut.authorizationHandler)
        XCTAssertEqual(makeControllerCallsCount, 1)
    }

    // MARK: - Submit

    func test_submit_shouldPresentSheet() async {
        let presented = expectation(description: "present called")
        controllerMock.onPresent = { presented.fulfill() }

        submit()

        await fulfillment(of: [presented], timeout: 5)
        XCTAssertTrue(controllerMock.delegate === sut.authorizationHandler)
        XCTAssertNotNil(sut.authorizationHandler)
    }

    func test_submit_whileSheetIsPresenting_shouldBeIgnored() {
        submit()

        sut.performSubmit()

        XCTAssertEqual(makeControllerCallsCount, 1)
    }

    func test_release_whileSheetIsOnScreen_shouldReleaseComponentAndStillDismissSheet() {
        let presented = expectation(description: "present called")
        controllerMock.onPresent = { presented.fulfill() }
        mockDelegate.onDidFail = { _, _ in XCTFail("A released component doesn't report") }
        submit()
        wait(for: [presented], timeout: 5)
        weak var releasedComponent: ApplePayComponent?
        releasedComponent = sut

        sut = nil

        XCTAssertNil(releasedComponent)

        // PassKit holds its delegate weakly, like the mock. The sheet task keeps the handler alive.
        let handler = controllerMock.delegate as? ApplePayAuthorizationHandler
        XCTAssertNotNil(handler)
        handler?.paymentAuthorizationControllerDidFinish(passKitController)

        wait(until: { self.controllerMock.dismissCallsCount == 1 }, timeout: 5, retryInterval: .milliseconds(10))
    }

    func test_submit_whenSheetCannotBePresented_shouldFailWithInvalidPaymentRequest() async {
        controllerMock.presentResult = false
        let didFail = expectation(description: "didFail called")
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidPaymentRequest)
            XCTAssertTrue(component === self.sut)
            didFail.fulfill()
        }

        submit()

        await fulfillment(of: [didFail], timeout: 5)
        XCTAssertNil(sut.authorizationHandler)
    }

    func test_cancel_shouldFailWithCancelledAndAllowNewSubmit() async {
        submit()
        let didFail = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ComponentError, .cancelled)
            didFail.fulfill()
        }
        mockDelegate.onDidSubmit = { _, _ in
            XCTFail("didSubmit must not fire")
        }

        finishSheet()
        await fulfillment(of: [didFail], timeout: 5)

        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
        XCTAssertNil(sut.authorizationHandler)

        sut.performSubmit()
        XCTAssertNotNil(sut.authorizationHandler)
        XCTAssertEqual(makeControllerCallsCount, 2)
    }

    // MARK: - Summary Item Handlers

    func testApplePayShipping() async throws {
        var receivedMethod: PKShippingMethod?
        var configuration = try makeConfiguration()
        configuration.onSelectShippingMethod = { method, _ in
            receivedMethod = method
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }
        sut = try makeComponent(configuration: configuration)
        submit()

        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")

        let shippingMethod = PKShippingMethod(label: "Shipping1", amount: 1.0)
        let result = await handler.paymentAuthorizationController(passKitController, didSelectShippingMethod: shippingMethod)

        XCTAssertEqual(receivedMethod, shippingMethod)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testApplePayShippingContact() async throws {
        var receivedContact: PKContact?
        var configuration = try makeConfiguration()
        configuration.onSelectShippingContact = { contact, _ in
            receivedContact = contact
            return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        let contact = PKContact()
        contact.name = PersonNameComponents()
        contact.name?.givenName = "Test"
        contact.name?.familyName = "Testovich"

        let result = await handler.paymentAuthorizationController(passKitController, didSelectShippingContact: contact)

        XCTAssertEqual(receivedContact, contact)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testApplePayCoupon() async throws {
        var receivedCoupon: String?
        var configuration = try makeConfiguration()
        configuration.onChangeCouponCode = { coupon, _ in
            receivedCoupon = coupon
            return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }
        sut = try makeComponent(configuration: configuration)
        submit()

        let result = await handler.paymentAuthorizationController(passKitController, didChangeCouponCode: "Coupon")

        XCTAssertEqual(receivedCoupon, "Coupon")
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testApplePayPaymentMethod() async throws {
        var receivedPaymentMethod: PKPaymentMethod?
        var configuration = try makeConfiguration()
        configuration.onSelectPaymentMethod = { paymentMethod, _ in
            receivedPaymentMethod = paymentMethod
            return PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }
        sut = try makeComponent(configuration: configuration)
        submit()

        let result = await handler.paymentAuthorizationController(passKitController, didSelectPaymentMethod: PKPaymentMethodMock())

        XCTAssertNotNil(receivedPaymentMethod)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testHandlers_withoutMerchantClosures_shouldKeepCurrentItems() async {
        submit()
        let originalItems = sut.paymentRequest.paymentSummaryItems

        let shippingMethodResult = await handler.paymentAuthorizationController(
            passKitController,
            didSelectShippingMethod: PKShippingMethod(label: "Shipping", amount: 1.0)
        )
        let shippingContactResult = await handler.paymentAuthorizationController(passKitController, didSelectShippingContact: PKContact())
        let couponResult = await handler.paymentAuthorizationController(passKitController, didChangeCouponCode: "Coupon")
        let paymentMethodResult = await handler.paymentAuthorizationController(passKitController, didSelectPaymentMethod: PKPaymentMethodMock())

        XCTAssertEqual(shippingMethodResult.paymentSummaryItems, originalItems)
        XCTAssertEqual(shippingContactResult.paymentSummaryItems, originalItems)
        XCTAssertEqual(couponResult.paymentSummaryItems, originalItems)
        XCTAssertEqual(paymentMethodResult.paymentSummaryItems, originalItems)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems, originalItems)
    }

    // MARK: - Invalid Summary Items

    func test_invalidSummaryItems_withNegativeGrandTotal_shouldCloseSheetAndFailOnce() async throws {
        try await assertInvalidSummaryItemsCloseSheet(
            [
                PKPaymentSummaryItem(label: "Item", amount: 10.0),
                PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: -1.0))
            ],
            failWith: .negativeGrandTotal
        )
    }

    func test_invalidSummaryItems_withNaNAmount_shouldCloseSheetAndFailOnce() async throws {
        try await assertInvalidSummaryItemsCloseSheet(
            [
                PKPaymentSummaryItem(label: "Item", amount: NSDecimalNumber.notANumber),
                PKPaymentSummaryItem(label: "Total", amount: 10.0)
            ],
            failWith: .invalidSummaryItem
        )
    }

    func testApplePayCoupon_givenDelegateReturnsEmptyItems_shouldKeepOriginalItems() async throws {
        var configuration = try makeConfiguration()
        configuration.onChangeCouponCode = { _, _ in
            PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: [])
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        let originalItems = sut.paymentRequest.paymentSummaryItems

        _ = await handler.paymentAuthorizationController(passKitController, didChangeCouponCode: "INVALID")

        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems, originalItems)
    }

    // MARK: - Authorization

    func test_didAuthorizeSuccess_shouldTriggerDidSubmit() async throws {
        var receivedPayment: PKPayment?
        var configuration = try makeConfiguration()
        configuration.onAuthorize = { payment in
            receivedPayment = payment
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
        sut = try makeComponent(configuration: configuration)
        submit()

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { data, _ in
            XCTAssertTrue(data.paymentMethod is ApplePayDetails)
            didSubmitExpectation.fulfill()
        }
        let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

        // When — run the authorization, then resolve it from outside once it's waiting for the result.
        let resultTask = Task {
            await self.handler.paymentAuthorizationController(self.passKitController, didAuthorizePayment: payment)
        }
        await fulfillment(of: [didSubmitExpectation], timeout: 5)
        XCTAssertNotNil(receivedPayment)

        let finalizeTask = startFinalize(success: true)
        let result = await resultTask.value
        XCTAssertEqual(result.status, .success)
        finishSheet()
        await finalizeTask.value
    }

    func test_didAuthorizeFailure_shouldNotTriggerDidSubmit() async throws {
        var configuration = try makeConfiguration()
        configuration.onAuthorize = { _ in
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: "Invalid postal code"
            )
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        mockDelegate.onDidSubmit = { _, _ in
            XCTFail("didSubmit should not be called when authorization fails")
        }
        let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

        let result = await handler.paymentAuthorizationController(passKitController, didAuthorizePayment: payment)

        XCTAssertEqual(result.status, .failure)
        XCTAssertEqual(result.errors?.count, 1)
    }

    func test_didAuthorizeWithEmptyToken_shouldFailOnceAfterSheetIsDismissed() async throws {
        var authorizeCalled = false
        var configuration = try makeConfiguration()
        configuration.onAuthorize = { _ in
            authorizeCalled = true
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        var errors: [Error] = []
        let didFail = expectation(description: "didFail(.invalidToken)")
        mockDelegate.onDidFail = { error, _ in
            errors.append(error)
            didFail.fulfill()
        }

        let result = await handler.paymentAuthorizationController(
            passKitController,
            didAuthorizePayment: PKPaymentMock.create(withPaymentData: Data())
        )

        XCTAssertEqual(result.status, .failure)
        XCTAssertFalse(authorizeCalled, "onAuthorize should not be called when token is empty")
        XCTAssertTrue(errors.isEmpty, "The error is reported once the sheet is gone")

        // PassKit closes the sheet by itself after a failure without errors.
        finishSheet()
        await fulfillment(of: [didFail], timeout: 5)
        await sut.finalize(success: false)

        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
        XCTAssertEqual(errors.count, 1, "No cancel may follow the failure")
        XCTAssertEqual(errors.first as? ApplePayComponent.Error, .invalidToken)
    }

    func test_finalize_shouldResolveSheetWithResult() async throws {
        for success in [true, false] {
            sut = try makeComponent(configuration: makeConfiguration())
            submit()
            let didSubmitExpectation = expectation(description: "didSubmit should be called")
            mockDelegate.onDidSubmit = { _, _ in didSubmitExpectation.fulfill() }
            let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

            let resultTask = Task {
                await self.handler.paymentAuthorizationController(self.passKitController, didAuthorizePayment: payment)
            }
            await fulfillment(of: [didSubmitExpectation], timeout: 5)

            let finalizeTask = startFinalize(success: success)

            let result = await resultTask.value
            XCTAssertEqual(result.status, success ? .success : .failure)
            finishSheet()
            await finalizeTask.value
        }
    }

    // MARK: - Sheet Task

    func test_finalize_shouldReturnOnlyAfterSheetIsDismissed() async throws {
        submit()
        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in didSubmitExpectation.fulfill() }
        let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let resultTask = Task {
            await self.handler.paymentAuthorizationController(self.passKitController, didAuthorizePayment: payment)
        }
        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        var finalized = false
        let finalizeTask = Task {
            await self.sut.finalize(success: true)
            finalized = true
        }
        let result = await resultTask.value
        // Give a wrong early return enough time to happen.
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(result.status, .success)
        XCTAssertFalse(finalized)
        XCTAssertEqual(controllerMock.dismissCallsCount, 0)

        finishSheet()
        await finalizeTask.value

        XCTAssertTrue(finalized)
        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
        XCTAssertNil(sut.authorizationHandler)
    }

    func test_finalize_withoutSheet_shouldReturnImmediately() async {
        await sut.finalize(success: true)

        XCTAssertEqual(controllerMock.dismissCallsCount, 0)
    }

    func test_finalize_afterSheetIsDismissed_shouldReturnImmediately() async {
        submit()
        let didFail = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { _, _ in didFail.fulfill() }
        finishSheet()
        await fulfillment(of: [didFail], timeout: 5)

        await sut.finalize(success: false)

        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
    }

    func test_didFinish_whilePresenting_shouldStillCloseSheet() async {
        controllerMock.onPresent = { [unowned self] in
            self.finishSheet()
        }
        let didFail = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ComponentError, .cancelled)
            didFail.fulfill()
        }

        submit()

        await fulfillment(of: [didFail], timeout: 5)
        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
        XCTAssertNil(sut.authorizationHandler)
    }

    // MARK: - Dismissal During Authorization

    /// The sheet finishes while `onAuthorize` is still running, for example after PassKit's timeout.
    /// This is reported as a cancel right away, and the payment isn't submitted, whatever `onAuthorize` returns.
    func test_finish_duringOnAuthorize_shouldReportCancelAndNotSubmit() async throws {
        for status in [PKPaymentAuthorizationStatus.success, .failure] {
            let onAuthorizeStarted = expectation(description: "onAuthorize entered")
            let releaseOnAuthorize = expectation(description: "release onAuthorize")
            var configuration = try makeConfiguration()
            configuration.onAuthorize = { _ in
                onAuthorizeStarted.fulfill()
                await self.fulfillment(of: [releaseOnAuthorize], timeout: 5)
                return PKPaymentAuthorizationResult(status: status, errors: nil)
            }
            sut = try makeComponent(configuration: configuration)
            submit()
            let handler = try XCTUnwrap(sut.authorizationHandler)

            var errors: [Error] = []
            let cancelled = expectation(description: "didFail(.cancelled)")
            mockDelegate.onDidFail = { error, _ in
                errors.append(error)
                cancelled.fulfill()
            }
            mockDelegate.onDidSubmit = { _, _ in XCTFail("didSubmit must not fire after the sheet finished") }
            let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

            let resultTask = Task {
                await handler.paymentAuthorizationController(self.passKitController, didAuthorizePayment: payment)
            }
            await fulfillment(of: [onAuthorizeStarted], timeout: 5)
            finishSheet()
            await fulfillment(of: [cancelled], timeout: 5)

            releaseOnAuthorize.fulfill()
            let result = await resultTask.value

            XCTAssertEqual(result.status, .failure)
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first as? ComponentError, .cancelled)
        }
    }

    /// The sheet closes after the payment was submitted, before the result arrives, for example after a PassKit timeout.
    /// This must not be reported as a cancel, and the suspended authorization ends because PassKit stopped waiting.
    func test_dismiss_duringSubmitContinuation_doesNotCallDidFailCancelled() async throws {
        submit()
        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in didSubmitExpectation.fulfill() }
        mockDelegate.onDidFail = { error, _ in XCTFail("didFail must not fire; got \(error)") }
        let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

        let resultTask = Task {
            await self.handler.paymentAuthorizationController(self.passKitController, didAuthorizePayment: payment)
        }
        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        finishSheet()
        // Give a wrong `didFail` enough time to fire.
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertEqual(controllerMock.dismissCallsCount, 1)
        XCTAssertNil(sut.authorizationHandler)
        let result = await resultTask.value
        XCTAssertEqual(result.status, .failure)

        await sut.finalize(success: true)
    }

    func test_dismiss_afterMerchantRejection_callsDidFailCancelled() async throws {
        var configuration = try makeConfiguration()
        configuration.onAuthorize = { _ in
            let postalCodeError = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: "Wrong postal code"
            )
            return PKPaymentAuthorizationResult(status: .failure, errors: [postalCodeError])
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        let didFailExpectation = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ComponentError, .cancelled)
            didFailExpectation.fulfill()
        }
        mockDelegate.onDidSubmit = { _, _ in
            XCTFail("didSubmit must not fire — merchant rejected before submit")
        }
        let payment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))

        let result = await handler.paymentAuthorizationController(passKitController, didAuthorizePayment: payment)
        XCTAssertEqual(result.status, .failure)

        finishSheet()

        await fulfillment(of: [didFailExpectation], timeout: 5)
    }

    // MARK: - Payment Request

    func testPaymentRequestViaSummeryItems() throws {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
        let countryCode = getRandomCountryCode()
        let currencyCode = getRandomCurrencyCode()
        let expectedSummaryItems = Dummy.createTestSummaryItems()
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()

        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = countryCode
        request.currencyCode = currencyCode
        request.paymentSummaryItems = expectedSummaryItems
        request.merchantCapabilities = .capability3DS
        request.requiredBillingContactFields = expectedRequiredBillingFields
        request.requiredShippingContactFields = expectedRequiredShippingFields

        let configuration = try ApplePayConfiguration(paymentRequest: request)
        configuration.paymentRequest.supportedNetworks = paymentMethod.supportedNetworks()
        let paymentRequest = configuration.paymentRequest
        XCTAssertEqual(paymentRequest.paymentSummaryItems, expectedSummaryItems)
        XCTAssertEqual(paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(paymentRequest.currencyCode, currencyCode)
        XCTAssertEqual(paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(paymentRequest.countryCode, countryCode)
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
        XCTAssertEqual(paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
    }

    func testNetworks() {
        if #available(iOS 15.1, *) {
            let request = PKPaymentRequest()
            let collection: [PKPaymentNetwork] = [.dankort]
            XCTAssertEqual(collection.count, 1)

            request.supportedNetworks = collection
            XCTAssertEqual(request.supportedNetworks.count, 1)
        }
    }

    func testPaymentRequestViaPayment() throws {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()
        let decimalAmount = AmountFormatter.decimalAmount(
            amount.value,
            currencyCode: amount.currencyCode
        )

        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = countryCode
        request.currencyCode = amount.currencyCode
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "TEST", amount: decimalAmount)]
        request.merchantCapabilities = .capability3DS
        request.requiredBillingContactFields = expectedRequiredBillingFields
        request.requiredShippingContactFields = expectedRequiredShippingFields

        let configuration = try ApplePayConfiguration(paymentRequest: request)
        configuration.paymentRequest.supportedNetworks = paymentMethod.supportedNetworks()
        let paymentRequest = configuration.paymentRequest

        XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 1)
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "TEST")
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.description, amount.formattedComponents.formattedValue)

        XCTAssertEqual(paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(paymentRequest.currencyCode, amount.currencyCode)
        XCTAssertEqual(paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(paymentRequest.countryCode, countryCode)
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
        XCTAssertEqual(paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
    }

    func testNewInitSuccess() throws {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = getRandomCountryCode()
        request.currencyCode = getRandomCurrencyCode()
        request.merchantCapabilities = [.capability3DS, .capabilityCredit]
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        request.recurringPaymentRequest = try PKRecurringPaymentRequest(
            paymentDescription: "recurring",
            regularBilling: .init(label: "recurring item", amount: 1500, type: .final),
            managementURL: XCTUnwrap(URL(string: "test"))
        )

        let config = try ApplePayConfiguration(paymentRequest: request)

        let component = try ApplePayComponent(paymentMethod: paymentMethod, context: Dummy.context, configuration: config)

        XCTAssertEqual(component.paymentRequest.countryCode, request.countryCode)
        XCTAssertEqual(component.paymentRequest.currencyCode, request.currencyCode)
        XCTAssertEqual(component.paymentRequest.paymentSummaryItems, request.paymentSummaryItems)
        XCTAssertNotNil(component.paymentRequest.recurringPaymentRequest)
        XCTAssertEqual(component.paymentRequest.supportedNetworks, paymentMethod.supportedNetworks())
    }

    func testNewInitMissingMerchantIdenfitifer() {
        let request = PKPaymentRequest()
        request.currencyCode = getRandomCurrencyCode()
        request.countryCode = getRandomCountryCode()
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        XCTAssertThrowsError(try ApplePayConfiguration(paymentRequest: request))
    }

    func testNewInitMissingCountryCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = getRandomCurrencyCode()
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        XCTAssertThrowsError(try ApplePayConfiguration(paymentRequest: request))
    }

    func testNewInitMissingCurrencyCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = getRandomCountryCode()
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        XCTAssertThrowsError(try ApplePayConfiguration(paymentRequest: request))
    }

    func testNewInitMissingSummaryItems() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = getRandomCurrencyCode()
        request.countryCode = getRandomCountryCode()

        XCTAssertThrowsError(try ApplePayConfiguration(paymentRequest: request))
    }

    func testReplacingSummaryItemsUSD() throws {
        // Given
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]
        let minorUnits = 1234
        let decimalAmount: NSDecimalNumber = 12.34 // USD decimals is 2
        let testAmount = Amount(value: minorUnits, currencyCode: "USD")
        let config = try ApplePayConfiguration(paymentRequest: request)

        // When
        let sut = config.replacing(amount: testAmount)

        // Then
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        let summaryItem = sut.paymentRequest.paymentSummaryItems.last
        XCTAssertNotNil(summaryItem)
        let expectedDecimalAmount = AmountFormatter.decimalAmount(
            testAmount.value,
            currencyCode: testAmount.currencyCode
        )
        XCTAssertEqual(summaryItem?.amount, expectedDecimalAmount)
        XCTAssertEqual(summaryItem?.amount, decimalAmount)
    }

    func testReplacingSummaryItemsJPY() throws {
        // Given
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = "JPY"
        request.countryCode = "JP"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]
        let minorUnits = 1234
        let decimalAmount: NSDecimalNumber = 1234.0 // JPY decimals is 0
        let testAmount = Amount(value: minorUnits, currencyCode: "JPY")
        let config = try ApplePayConfiguration(paymentRequest: request)

        // When
        let sut = config.replacing(amount: testAmount)

        // Then
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        let summaryItem = sut.paymentRequest.paymentSummaryItems.last
        XCTAssertNotNil(summaryItem)
        let expectedDecimalAmount = AmountFormatter.decimalAmount(
            testAmount.value,
            currencyCode: testAmount.currencyCode
        )
        XCTAssertEqual(summaryItem?.amount, expectedDecimalAmount)
        XCTAssertEqual(summaryItem?.amount, decimalAmount)
    }

    func testBrandsFiltering() {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: ["mc", "elo", "unknown_network"])
        let supportedNetworks = paymentMethod.supportedNetworks()

        XCTAssertTrue(compareCollections(supportedNetworks, [.masterCard, .elo]))
    }

    private func getRandomContactFieldSet() -> Set<PKContactField> {
        let contactFieldsPool: [PKContactField] = [.emailAddress, .name, .phoneNumber, .postalAddress, .phoneticName]
        return contactFieldsPool.randomElement().map { [$0] } ?? []
    }
    
    private func makeComponent(
        configuration: ApplePayConfiguration,
        context: AdyenContext = Dummy.context
    ) throws -> ApplePayComponent {
        let component = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
        component.makeAuthorizationController = { [unowned self] _ in
            self.makeControllerCallsCount += 1
            return self.controllerMock
        }
        return component
    }

    /// Submits the component, so it presents the sheet through `controllerMock`.
    private func submit() {
        sut.delegate = mockDelegate
        sut.performSubmit()
    }

    /// Delivers PassKit's signal that the sheet finished.
    private func finishSheet(file: StaticString = #filePath, line: UInt = #line) {
        guard let handler = sut.authorizationHandler else {
            return XCTFail("No sheet is on screen", file: file, line: line)
        }
        handler.paymentAuthorizationControllerDidFinish(passKitController)
    }

    /// Returns `items` from `onSelectShippingMethod` and checks that the sheet closes and reports `expectedError` once.
    private func assertInvalidSummaryItemsCloseSheet(
        _ items: [PKPaymentSummaryItem],
        failWith expectedError: ApplePayComponent.Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        var configuration = try makeConfiguration()
        configuration.onSelectShippingMethod = { _, _ in
            PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
        }
        sut = try makeComponent(configuration: configuration)
        submit()
        let handler = try XCTUnwrap(sut.authorizationHandler)
        let originalItems = sut.paymentRequest.paymentSummaryItems
        var errors: [Error] = []
        let didFail = expectation(description: "didFail(\(expectedError))")
        mockDelegate.onDidFail = { error, _ in
            errors.append(error)
            didFail.fulfill()
        }

        let result = await handler.paymentAuthorizationController(
            passKitController,
            didSelectShippingMethod: PKShippingMethod(label: "Shipping", amount: 5.0)
        )
        await fulfillment(of: [didFail], timeout: 5)

        XCTAssertEqual(result.paymentSummaryItems, originalItems, file: file, line: line)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems, originalItems, file: file, line: line)
        XCTAssertEqual(controllerMock.dismissCallsCount, 1, "The sheet closes without PassKit's didFinish", file: file, line: line)
        XCTAssertNil(sut.authorizationHandler, file: file, line: line)

        // PassKit can still report that the sheet finished.
        handler.paymentAuthorizationControllerDidFinish(passKitController)
        // Give a wrong cancel enough time to fire.
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(errors.count, 1, "No cancel may follow the error", file: file, line: line)
        XCTAssertEqual(errors.first as? ApplePayComponent.Error, expectedError, file: file, line: line)

        // A new sheet doesn't report the old error.
        let cancelled = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ComponentError, .cancelled, file: file, line: line)
            cancelled.fulfill()
        }
        sut.performSubmit()
        finishSheet()
        await fulfillment(of: [cancelled], timeout: 5)
    }

    /// Starts `finalize(success:)`, which returns only once the sheet is dismissed.
    private func startFinalize(success: Bool) -> Task<Void, Never> {
        Task { await self.sut.finalize(success: success) }
    }

    private func makeConfiguration() throws -> ApplePayConfiguration {
        try ApplePayConfiguration(paymentRequest: Dummy.createTestApplePayPaymentRequest())
    }
}

// MARK: - PKPaymentAuthorizationController Mock

@MainActor
final class ApplePayAuthorizationControllerMock: ApplePayAuthorizationControlling {

    weak var delegate: PKPaymentAuthorizationControllerDelegate?

    var presentResult = true
    var onPresent: (() -> Void)?
    private(set) var dismissCallsCount = 0

    func present() async -> Bool {
        onPresent?()
        return presentResult
    }

    func dismiss() async {
        dismissCallsCount += 1
    }
}

// MARK: - PKPayment Mock

/// Mock PKPayment for testing purposes.
/// PKPayment cannot be instantiated directly, so we use a subclass with mocked properties.
private final class PKPaymentMock: PKPayment {
    
    private let _token: PKPaymentToken
    private let _billingContact: PKContact?
    private let _shippingContact: PKContact?
    private let _shippingMethod: PKShippingMethod?
    
    override var token: PKPaymentToken {
        _token
    }

    override var billingContact: PKContact? {
        _billingContact
    }

    override var shippingContact: PKContact? {
        _shippingContact
    }

    override var shippingMethod: PKShippingMethod? {
        _shippingMethod
    }
    
    private init(
        token: PKPaymentToken,
        billingContact: PKContact? = nil,
        shippingContact: PKContact? = nil,
        shippingMethod: PKShippingMethod? = nil
    ) {
        self._token = token
        self._billingContact = billingContact
        self._shippingContact = shippingContact
        self._shippingMethod = shippingMethod
        super.init()
    }
    
    static func create(
        withPaymentData paymentData: Data,
        billingContact: PKContact? = nil,
        shippingContact: PKContact? = nil,
        shippingMethod: PKShippingMethod? = nil
    ) -> PKPaymentMock {
        let token = PKPaymentTokenMock(paymentData: paymentData)
        return PKPaymentMock(
            token: token,
            billingContact: billingContact,
            shippingContact: shippingContact,
            shippingMethod: shippingMethod
        )
    }
}

/// Mock PKPaymentToken for testing purposes.
private final class PKPaymentTokenMock: PKPaymentToken {
    
    private let _paymentData: Data
    private let _paymentMethod: PKPaymentMethod
    
    override var paymentData: Data {
        _paymentData
    }

    override var paymentMethod: PKPaymentMethod {
        _paymentMethod
    }
    
    init(paymentData: Data) {
        self._paymentData = paymentData
        self._paymentMethod = PKPaymentMethodMock()
        super.init()
    }
}

/// Mock PKPaymentMethod for testing purposes.
private final class PKPaymentMethodMock: PKPaymentMethod {
    
    override var network: PKPaymentNetwork? {
        .visa
    }

    override var type: PKPaymentMethodType {
        .credit
    }

    override var displayName: String? {
        "Test Card"
    }
}

extension XCTestCase {

    func compareCollections<T: Hashable>(_ lhs: [T], _ rhs: [T]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }

        let lhsSet = Set<T>(lhs)
        let rhsSet = Set<T>(rhs)
        return lhsSet.intersection(rhsSet).count == lhs.count
    }

}
