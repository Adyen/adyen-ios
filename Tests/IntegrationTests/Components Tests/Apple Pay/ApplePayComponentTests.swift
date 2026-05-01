//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
import Contacts
import PassKit
import XCTest

@MainActor
class ApplePayComponentTest: XCTestCase {

    var mockDelegate: PaymentComponentDelegateMock!
    var sut: ApplePayComponent!
    lazy var amount = Amount(value: 2, currencyCode: "USD")
    lazy var countryCode = getRandomCountryCode()
    let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: ["visa", "amex", "mc"])

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
            sut = try ApplePayComponent(
                paymentMethod: paymentMethod,
                context: Dummy.context,
                configuration: configuration
            )
        } catch {
            XCTFail("setUp failed to create ApplePayComponent: \(error)")
        }
        mockDelegate = PaymentComponentDelegateMock()
    }

    override func tearDown() {
        sut = nil
        mockDelegate = nil
        
        UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.dismiss(animated: false)
        setupRootViewController(emptyVC)
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

        XCTAssertEqual(config.paymentRequest.merchantIdentifier, request.merchantIdentifier)
        XCTAssertFalse(config.allowOnboarding)
    }

    // MARK: - Component Tests

    func testApplePay_givenBrandsIsEmpty_shouldThrowUserCannotMakePayment() throws {
        // Given
        let brands: [String]? = []
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: brands)
        let configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )

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

    func testApplePayViewControllerShouldCallDelegateDidFail() throws {
        // This is necessary to give ApplePay time to disappear from screen.
        wait(for: .seconds(2))

        sut.delegate = mockDelegate
        let viewController = try XCTUnwrap(sut?.viewController)
        let onDidFailExpectation = expectation(description: "Wait for delegate call")
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            onDidFailExpectation.fulfill()
            self.mockDelegate = nil // to prevent false triggering
        }

        viewController.loadViewIfNeeded()
        try self.sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(viewController as? PKPaymentAuthorizationViewController))

        waitForExpectations(timeout: 10)
    }

    func testApplePayShipping() async throws {
        var receivedMethod: PKShippingMethod?
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onShippingMethodChange = { method, _ in
            receivedMethod = method
            return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        let shippingMethods = [PKShippingMethod(label: "Shipping1", amount: 1.0), PKShippingMethod(label: "Shipping2", amount: 2.0)]
        shippingMethods.forEach { $0.identifier = UUID().uuidString }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        try await Task.sleep(for: .seconds(1))

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        let selectedShippingMethod = try XCTUnwrap(shippingMethods.first)

        let result = await sut.paymentAuthorizationViewController(controller, didSelect: selectedShippingMethod)

        XCTAssertEqual(receivedMethod, shippingMethods.first)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testApplePayShippingContact() async throws {
        var receivedContact: PKContact?
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onShippingContactChange = { contact, _ in
            receivedContact = contact
            return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        try await Task.sleep(for: .seconds(1))
        let contact = PKContact()
        contact.name = PersonNameComponents()
        contact.name?.givenName = "Test"
        contact.name?.familyName = "Testovich"

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        let result = await sut.paymentAuthorizationViewController(controller, didSelectShippingContact: contact)

        XCTAssertEqual(receivedContact, contact)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    func testApplePayCoupon() async throws {
        var receivedCoupon: String?
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onCouponCodeChange = { coupon, _ in
            receivedCoupon = coupon
            return PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        try await Task.sleep(for: .seconds(1))

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        let result = await sut.paymentAuthorizationViewController(controller, didChangeCouponCode: "Coupon")

        XCTAssertEqual(receivedCoupon, "Coupon")
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
        XCTAssertEqual(result.paymentSummaryItems.count, 2)
    }

    // MARK: - Delegate Invalid Summary Items Tests

    func testApplePayShipping_givenDelegateReturnsNegativeGrandTotal_shouldKeepOriginalItemsAndCallDidFail() async throws {
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onShippingMethodChange = { _, _ in
            PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "Item", amount: 10.0),
                PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: -1.0))
            ])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        try await Task.sleep(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems
        let onDidFail = expectation(description: "Wait for didFail call")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ApplePayComponent.Error, .negativeGrandTotal)
            onDidFail.fulfill()
        }
        let shippingMethod = PKShippingMethod(label: "Shipping", amount: 5.0)

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        let result = await sut.paymentAuthorizationViewController(controller, didSelect: shippingMethod)

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)

        await fulfillment(of: [onDidFail], timeout: 10)
    }

    func testApplePayShippingContact_givenDelegateReturnsNaNAmount_shouldKeepOriginalItemsAndCallDidFail() async throws {
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onShippingContactChange = { _, _ in
            PKPaymentRequestShippingContactUpdate(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "Item", amount: NSDecimalNumber.notANumber),
                PKPaymentSummaryItem(label: "Total", amount: 10.0)
            ])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        try await Task.sleep(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems
        let onDidFail = expectation(description: "Wait for didFail call")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidSummaryItem)
            onDidFail.fulfill()
        }
        let contact = PKContact()

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        _ = await sut.paymentAuthorizationViewController(controller, didSelectShippingContact: contact)

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)

        await fulfillment(of: [onDidFail], timeout: 10)
    }

    func testApplePayCoupon_givenDelegateReturnsEmptyItems_shouldKeepOriginalItems() async throws {
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onCouponCodeChange = { _, _ in
            PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: [])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        try await Task.sleep(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        _ = await sut.paymentAuthorizationViewController(controller, didChangeCouponCode: "INVALID")

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)
    }

    // MARK: - Presentation Tests

    func testPresentationViewControllerValidPayment() {
        XCTAssertTrue(sut?.viewController is PKPaymentAuthorizationViewController)
    }

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
            currencyCode: amount.currencyCode,
            localeIdentifier: amount.localeIdentifier
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
        XCTAssertEqual(sut.currentAmount, testAmount)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        let summaryItem = sut.paymentRequest.paymentSummaryItems.last
        XCTAssertNotNil(summaryItem)
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
        XCTAssertEqual(sut.currentAmount, testAmount)
        XCTAssertEqual(sut.paymentRequest.paymentSummaryItems.count, 2)
        let summaryItem = sut.paymentRequest.paymentSummaryItems.last
        XCTAssertNotNil(summaryItem)
        XCTAssertEqual(summaryItem?.amount, decimalAmount)
    }

    func testBrandsFiltering() {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: ["mc", "elo", "unknown_network"])
        let supportedNetworks = paymentMethod.supportedNetworks()

        XCTAssertTrue(compareCollections(supportedNetworks, [.masterCard, .elo]))
    }

    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)

        let configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        // When
        sut.viewController.loadViewIfNeeded()

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)

        // access view controller again but not trigger render
        sut.viewController.loadViewIfNeeded()
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)

    }

    private func getRandomContactFieldSet() -> Set<PKContactField> {
        let contactFieldsPool: [PKContactField] = [.emailAddress, .name, .phoneNumber, .postalAddress, .phoneticName]
        return contactFieldsPool.randomElement().map { [$0] } ?? []
    }
    
    // MARK: - didAuthorize Tests (async)

    func test_didAuthorizeSuccess_shouldTriggerDidSubmit() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        var receivedPayment: PKPayment?
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onAuthorize = { payment in
            receivedPayment = payment
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { data, _ in
            XCTAssertTrue(data.paymentMethod is ApplePayDetails)
            didSubmitExpectation.fulfill()
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When — launch the async delegate in a Task, then resolve from outside
        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }

        // Wait for didSubmit to fire (meaning the component has suspended on the continuation)
        await fulfillment(of: [didSubmitExpectation], timeout: 5)
        XCTAssertNotNil(receivedPayment)

        // Resolve the continuation so the async method can return
        await sut.didFinalize(with: true, completion: nil)
        let result = await resultTask.value
        XCTAssertEqual(result.status, .success)
    }

    func test_didAuthorizeFailure_shouldNotTriggerDidSubmit() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onAuthorize = { _ in
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: "Invalid postal code"
            )
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        var didSubmitCalled = false
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitCalled = true
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When
        let result = await sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)

        // Then — onAuthorize returned failure, so didSubmit should NOT have been called
        XCTAssertEqual(result.status, .failure)
        XCTAssertEqual(result.errors?.count, 1)
        XCTAssertFalse(didSubmitCalled, "didSubmit should not be called when authorization fails")
    }

    func test_didAuthorizeWithoutOnAuthorize_shouldAutoApproveAndSubmit() async throws {
        // Given — no onAuthorize closure set
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { data, _ in
            XCTAssertTrue(data.paymentMethod is ApplePayDetails)
            didSubmitExpectation.fulfill()
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When
        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }

        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        // Resolve so the async method finishes
        await sut.didFinalize(with: true, completion: nil)
        let result = await resultTask.value
        XCTAssertEqual(result.status, .success)
    }

    func test_didAuthorizeWithEmptyToken_shouldFailImmediately() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate

        let didFailExpectation = expectation(description: "didFail should be called")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidToken)
            didFailExpectation.fulfill()
        }

        var authorizeCalled = false
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onAuthorize = { _ in
            authorizeCalled = true
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        let mockPayment = PKPaymentMock.create(withPaymentData: Data()) // Empty token
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When
        let result = await sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)

        // Then
        XCTAssertEqual(result.status, .failure)
        await fulfillment(of: [didFailExpectation], timeout: 5)
        XCTAssertFalse(authorizeCalled, "onAuthorize should not be called when token is empty")
    }

    // MARK: - resolve Tests

    func test_resolve_success_shouldResumeWithSuccess() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }

        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        // When
        await sut.didFinalize(with: true, completion: nil)

        // Then
        let result = await resultTask.value
        XCTAssertEqual(result.status, .success)
    }

    func test_resolve_failure_shouldResumeWithFailure() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }

        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        // When
        await sut.didFinalize(with: false, completion: nil)

        // Then
        let result = await resultTask.value
        XCTAssertEqual(result.status, .failure)
    }

    // MARK: - Dismissal During Authorization Flow

    /// Flow C: shopper dismisses the sheet while `await onAuthorize` is suspended.
    /// With the entry-time `authorizationHandled = true`, `didFinish` must NOT
    /// emit `didFail(.cancelled)` even though the flag was previously interpreted
    /// as "auth completed". The merchant's onAuthorize result still drives the
    /// downstream flow normally.
    func test_dismiss_duringAwaitOnAuthorize_doesNotCallDidFailCancelled() async throws {
        // Given
        try await Task.sleep(for: .seconds(1))

        let onAuthorizeStarted = expectation(description: "onAuthorize entered")
        let releaseOnAuthorize = expectation(description: "release onAuthorize")
        var configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.onAuthorize = { _ in
            onAuthorizeStarted.fulfill()
            // Simulate a slow merchant validation; release only after dismissal.
            await self.fulfillment(of: [releaseOnAuthorize], timeout: 5)
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called once")
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }
        mockDelegate.onDidFail = { error, _ in
            XCTFail("didFail must not fire; got \(error)")
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When — drive the async delegate, wait until it suspends inside onAuthorize, then dismiss.
        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }
        await fulfillment(of: [onAuthorizeStarted], timeout: 5)
        try sut.paymentAuthorizationViewControllerDidFinish(controller)

        // Release onAuthorize -> code proceeds to submit -> continuation stored.
        releaseOnAuthorize.fulfill()
        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        // Resolve so the auth task can return.
        await sut.didFinalize(with: true, completion: nil)
        let result = await resultTask.value

        // Then
        XCTAssertEqual(result.status, .success)
    }

    /// Flow D: shopper dismisses the sheet after `submit(data:)` fired the
    /// backend call (continuation suspended) but before `didFinalize` resumes it.
    /// The fix prevents a spurious `didFail(.cancelled)` from racing alongside
    /// the merchant's eventual `didFinalize` for the in-flight payment.
    func test_dismiss_duringSubmitContinuation_doesNotCallDidFailCancelled() async throws {
        // Given — no onAuthorize; auth goes straight to submit.
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate

        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }
        mockDelegate.onDidFail = { error, _ in
            XCTFail("didFail must not fire; got \(error)")
        }

        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)

        // When — drive auth, wait until the component suspends on the continuation, then dismiss.
        let resultTask = Task {
            await self.sut.paymentAuthorizationViewController(controller, didAuthorizePayment: mockPayment)
        }
        await fulfillment(of: [didSubmitExpectation], timeout: 5)

        try sut.paymentAuthorizationViewControllerDidFinish(controller)

        // Give any spurious `didFail` enough time to fire if the regression returns.
        try await Task.sleep(for: .milliseconds(200))

        // Resolve so the auth task can return.
        await sut.didFinalize(with: true, completion: nil)
        let result = await resultTask.value

        // Then
        XCTAssertEqual(result.status, .success)
    }

    /// Sanity check: dismissal BEFORE the shopper taps Pay still surfaces as
    /// `didFail(.cancelled)`. The fix must not regress this path.
    func test_dismiss_beforeAuthorize_callsDidFailCancelled() async throws {
        try await Task.sleep(for: .seconds(1))

        sut.delegate = mockDelegate
        let didFailExpectation = expectation(description: "didFail(.cancelled)")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ComponentError, .cancelled)
            didFailExpectation.fulfill()
        }
        mockDelegate.onDidSubmit = { _, _ in
            XCTFail("didSubmit must not fire")
        }

        let controller = try XCTUnwrap(sut.paymentAuthorizationViewController)
        try sut.paymentAuthorizationViewControllerDidFinish(controller)

        await fulfillment(of: [didFailExpectation], timeout: 5)
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
        if lhs.count != rhs.count { return false }

        let lhsSet = Set<T>(lhs)
        let rhsSet = Set<T>(rhs)
        return lhsSet.intersection(rhsSet).count == lhs.count
    }

}
