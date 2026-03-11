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

class ApplePayComponentTest: XCTestCase {

    var mockDelegate: PaymentComponentDelegateMock!
    var mockApplePayDelegate: ApplePayDelegateMock!
    var mockAuthorizationDelegate: ApplePayAuthorizationDelegateMock!
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
        let configuration = try! ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        sut = try! ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        mockDelegate = PaymentComponentDelegateMock()
        mockApplePayDelegate = ApplePayDelegateMock()
        mockAuthorizationDelegate = ApplePayAuthorizationDelegateMock()
    }

    override func tearDown() {
        sut = nil
        mockDelegate = nil
        mockAuthorizationDelegate = nil
        
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
            try ApplePayComponent.Configuration(paymentRequest: request)
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
            try ApplePayComponent.Configuration(paymentRequest: request)
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
            try ApplePayComponent.Configuration(paymentRequest: request)
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
            try ApplePayComponent.Configuration(paymentRequest: request)
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
            try ApplePayComponent.Configuration(paymentRequest: request)
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
            try ApplePayComponent.Configuration(paymentRequest: request)
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidSummaryItem)
        }
    }

    func testConfiguration_givenValidRequest_shouldSucceed() throws {
        let request = Dummy.createTestApplePayPaymentRequest()

        let config = try ApplePayComponent.Configuration(paymentRequest: request)

        XCTAssertEqual(config.merchantIdentifier, request.merchantIdentifier)
        XCTAssertFalse(config.allowOnboarding)
    }

    // MARK: - Component Tests

    func testApplePay_givenBrandsIsEmpty_shouldThrowUserCannotMakePayment() throws {
        // Given
        let brands: [String]? = []
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: brands)
        let configuration = try ApplePayComponent.Configuration(
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
        
        // After cancel, component should be reusable with a new view controller
        XCTAssertTrue(viewController !== self.sut.viewController)
    }

    func testApplePayViewControllerShouldCallFinalizeCompletion() throws {
        // This is necessary to give ApplePay time to disappear from screen.
        wait(for: .seconds(2))

        let viewController = try XCTUnwrap(sut?.viewController)
        let onDidFinalizeExpectation = expectation(description: "Wait for didFinalize call")

        viewController.loadViewIfNeeded()

        sut.finalizeIfNeeded(with: true) {
            onDidFinalizeExpectation.fulfill()
        }
        try sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(viewController as? PKPaymentAuthorizationViewController))

        waitForExpectations(timeout: 10)
    }

    func testApplePayShipping() throws {
        let configuration = try ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        let shippingMethods = [PKShippingMethod(label: "Shipping1", amount: 1.0), PKShippingMethod(label: "Shipping2", amount: 2.0)]
        shippingMethods.forEach { $0.identifier = UUID().uuidString }

        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onShippingMethodChange = { method, payment in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        wait(for: .seconds(1))
        let onShippingSelected = expectation(description: "Wait for didFinalize call")
        let selectedShippingMethod: PKShippingMethod? = shippingMethods.first

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")

        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didSelect: XCTUnwrap(selectedShippingMethod)
        ) { update in
            XCTAssertEqual(self.mockApplePayDelegate.shippingMethod, shippingMethods.first)
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
            onShippingSelected.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testApplePayShippingContact() throws {
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onShippingContactChange = { contact, payment in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        wait(for: .seconds(1))
        let onContactSelected = expectation(description: "Wait for didFinalize call")
        let contact = PKContact()
        contact.name = PersonNameComponents()
        contact.name?.givenName = "Test"
        contact.name?.familyName = "Testovich"

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didSelectShippingContact: contact
        ) { update in

            XCTAssertEqual(self.mockApplePayDelegate.contact, contact)
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
            onContactSelected.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testApplePayCoupon() throws {
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onCouponChange = { coupon, payment in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        wait(for: .seconds(1))
        let onContactSelected = expectation(description: "Wait for didFinalize call")

        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 5)
        XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "summary_4")
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didChangeCouponCode: "Coupon"
        ) { update in

            XCTAssertEqual(self.mockApplePayDelegate.couponCode, "Coupon")
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.count, 2)
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems.last?.label, "New Item 2")
            onContactSelected.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    // MARK: - Delegate Invalid Summary Items Tests

    func testApplePayShipping_givenDelegateReturnsNegativeGrandTotal_shouldKeepOriginalItemsAndCallDidFail() throws {
        sut.delegate = mockDelegate
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onShippingMethodChange = { _, _ in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "Item", amount: 10.0),
                PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: -1.0))
            ])
        }

        wait(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems
        let onShippingSelected = expectation(description: "Wait for shipping method callback")
        let onDidFail = expectation(description: "Wait for didFail call")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ApplePayComponent.Error, .negativeGrandTotal)
            onDidFail.fulfill()
        }
        let shippingMethod = PKShippingMethod(label: "Shipping", amount: 5.0)

        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didSelect: shippingMethod
        ) { _ in
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)
            onShippingSelected.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testApplePayShippingContact_givenDelegateReturnsNaNAmount_shouldKeepOriginalItemsAndCallDidFail() throws {
        sut.delegate = mockDelegate
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onShippingContactChange = { _, _ in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "Item", amount: NSDecimalNumber.notANumber),
                PKPaymentSummaryItem(label: "Total", amount: 10.0)
            ])
        }

        wait(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems
        let onContactSelected = expectation(description: "Wait for shipping contact callback")
        let onDidFail = expectation(description: "Wait for didFail call")
        mockDelegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidSummaryItem)
            onDidFail.fulfill()
        }
        let contact = PKContact()

        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didSelectShippingContact: contact
        ) { _ in
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)
            onContactSelected.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testApplePayCoupon_givenDelegateReturnsEmptyItems_shouldKeepOriginalItems() throws {
        sut.applePayDelegate = mockApplePayDelegate
        mockApplePayDelegate.onCouponChange = { _, _ in
            .init(paymentSummaryItems: [])
        }

        wait(for: .seconds(1))
        let originalItems = sut.paymentRequest.paymentSummaryItems
        let onCouponChanged = expectation(description: "Wait for coupon code callback")

        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut?.viewController as? PKPaymentAuthorizationViewController),
            didChangeCouponCode: "INVALID"
        ) { _ in
            XCTAssertEqual(self.sut.paymentRequest.paymentSummaryItems, originalItems)
            onCouponChanged.fulfill()
        }

        waitForExpectations(timeout: 10)
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

        var configuration = try ApplePayComponent.Configuration(paymentRequest: request)
        let paymentRequest = configuration.paymentRequest(with: paymentMethod.supportedNetworks())
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

        var configuration = try ApplePayComponent.Configuration(paymentRequest: request)
        let paymentRequest = configuration.paymentRequest(with: paymentMethod.supportedNetworks())

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
        guard #available(iOS 16.0, *) else {
            // XCTestCase does not respect @available so we have to skip the test like this
            throw XCTSkip("Unsupported iOS version")
        }

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

        let config = try ApplePayComponent.Configuration(paymentRequest: request)

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

        XCTAssertThrowsError(try ApplePayComponent.Configuration(paymentRequest: request))
    }

    func testNewInitMissingCountryCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = getRandomCurrencyCode()
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        XCTAssertThrowsError(try ApplePayComponent.Configuration(paymentRequest: request))
    }

    func testNewInitMissingCurrencyCode() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.countryCode = getRandomCountryCode()
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
            PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
        ]

        XCTAssertThrowsError(try ApplePayComponent.Configuration(paymentRequest: request))
    }

    func testNewInitMissingSummaryItems() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "test_id"
        request.currencyCode = getRandomCurrencyCode()
        request.countryCode = getRandomCountryCode()

        XCTAssertThrowsError(try ApplePayComponent.Configuration(paymentRequest: request))
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
        let config = try ApplePayComponent.Configuration(paymentRequest: request)

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
        let config = try ApplePayComponent.Configuration(paymentRequest: request)

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

    // MARK: - dismissesAutomatically Tests
    
    func test_DismissesAutomatically_WhenFalse_ShouldCallDidFailImmediately() throws {
        // Given
        var configuration = try ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.dismissesAutomatically = false
        
        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate
        
        let viewController = sut.viewController
        let onDidFailExpectation = expectation(description: "didFail should be called")
        
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            onDidFailExpectation.fulfill()
        }
        
        viewController.loadViewIfNeeded()
        
        // When
        try sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(viewController as? PKPaymentAuthorizationViewController))
        
        // Then - should be called immediately (not waiting for dismiss animation)
        waitForExpectations(timeout: 2)
    }
    
    func test_DismissesAutomatically_WhenFalse_ShouldCallFinalizeCompletionImmediately() throws {
        // Given
        var configuration = try ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.dismissesAutomatically = false
        
        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        
        let viewController = sut.viewController
        let onDidFinalizeExpectation = expectation(description: "finalize completion should be called")
        
        viewController.loadViewIfNeeded()
        
        sut.finalizeIfNeeded(with: true) {
            onDidFinalizeExpectation.fulfill()
        }
        
        // When
        try sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(viewController as? PKPaymentAuthorizationViewController))
        
        // Then - should be called immediately
        waitForExpectations(timeout: 2)
    }
    
    func test_ComponentReuse_WhenCancelledBeforeAuthorization_ShouldAllowReuse() throws {
        // Given
        var configuration = try ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.dismissesAutomatically = false
        
        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate
        
        let firstViewController = sut.viewController
        
        let onDidFailExpectation = expectation(description: "didFail should be called")
        mockDelegate.onDidFail = { _, _ in
            onDidFailExpectation.fulfill()
        }
        
        firstViewController.loadViewIfNeeded()
        
        // When - user cancels before authorization (state is .initial)
        try sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(firstViewController as? PKPaymentAuthorizationViewController))
        
        waitForExpectations(timeout: 2)
        
        // Then - component should be reusable with a new view controller
        let secondViewController = sut.viewController
        XCTAssertTrue(firstViewController !== secondViewController, "A new view controller should be created after cancel")
    }
    
    func test_ComponentReuse_WhenPaymentAuthorized_ShouldNotAllowReuse() throws {
        // Given
        wait(for: .seconds(1))
        
        var configuration = try ApplePayComponent.Configuration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )
        configuration.dismissesAutomatically = false
        
        sut = try ApplePayComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        sut.delegate = mockDelegate
        
        let firstViewController = sut.viewController
        
        let onDidSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { _, _ in
            onDidSubmitExpectation.fulfill()
        }
        
        firstViewController.loadViewIfNeeded()
        
        // When - payment is authorized (moves to .submitted state)
        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(firstViewController as? PKPaymentAuthorizationViewController),
            didAuthorizePayment: mockPayment
        ) { _ in }
        
        waitForExpectations(timeout: 5)
        
        // Then simulate didFinish without calling finalizeIfNeeded
        try sut.paymentAuthorizationViewControllerDidFinish(XCTUnwrap(firstViewController as? PKPaymentAuthorizationViewController))
        
        // Component should NOT be reusable - same view controller returned
        let secondViewController = sut.viewController
        XCTAssertTrue(firstViewController === secondViewController, "Same view controller should be returned after authorization")
    }
    
    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)

        let configuration = try ApplePayComponent.Configuration(
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
    
    // MARK: - didAuthorize Tests
    
    func test_didAuthorizeSuccess_shouldTriggerDidSubmit() throws {
        // Given
        wait(for: .seconds(1))
        
        sut.delegate = mockDelegate
        sut.authorizationDelegate = mockAuthorizationDelegate
        
        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { data, component in
            XCTAssertTrue(data.paymentMethod is ApplePayDetails)
            didSubmitExpectation.fulfill()
        }
        
        mockAuthorizationDelegate.onAuthorize = { payment in
            // Simulate successful validation
            PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
        
        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        
        // When
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut.viewController as? PKPaymentAuthorizationViewController),
            didAuthorizePayment: mockPayment
        ) { result in
            // This completion is called after finalize, not after authorize
        }
        
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertNotNil(mockAuthorizationDelegate.authorizedPayment)
    }
    
    func test_didAuthorizeFailure_shouldNotTriggerDidSubmit() throws {
        // Given
        wait(for: .seconds(1))
        
        sut.delegate = mockDelegate
        sut.authorizationDelegate = mockAuthorizationDelegate
        
        var didSubmitCalled = false
        mockDelegate.onDidSubmit = { _, _ in
            didSubmitCalled = true
        }
        
        let authorizationCompletionExpectation = expectation(description: "Authorization completion should be called with failure")
        
        mockAuthorizationDelegate.onAuthorize = { payment in
            // Simulate validation failure with specific errors
            let error = PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: CNPostalAddressPostalCodeKey,
                localizedDescription: "Invalid postal code"
            )
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }
        
        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        
        // When
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut.viewController as? PKPaymentAuthorizationViewController),
            didAuthorizePayment: mockPayment
        ) { result in
            // Completion should be called with failure result
            XCTAssertEqual(result.status, .failure)
            XCTAssertEqual(result.errors?.count, 1)
            authorizationCompletionExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertFalse(didSubmitCalled, "didSubmit should not be called when authorization fails")
        XCTAssertNotNil(mockAuthorizationDelegate.authorizedPayment)
    }
    
    func test_didAuthorizeWithoutDelegate_shouldAutoApproveAndSubmit() throws {
        // Given
        wait(for: .seconds(1))
        
        sut.delegate = mockDelegate
        // Note: authorizationDelegate is NOT set - should use default behavior
        
        let didSubmitExpectation = expectation(description: "didSubmit should be called")
        mockDelegate.onDidSubmit = { data, component in
            XCTAssertTrue(data.paymentMethod is ApplePayDetails)
            didSubmitExpectation.fulfill()
        }
        
        let mockPayment = try PKPaymentMock.create(withPaymentData: XCTUnwrap("test_token".data(using: .utf8)))
        
        // When
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut.viewController as? PKPaymentAuthorizationViewController),
            didAuthorizePayment: mockPayment
        ) { result in
            // Completion called after finalize
        }
        
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_didAuthorizeWithEmptyToken_shouldFailImmediately() throws {
        // Given
        wait(for: .seconds(1))
        
        sut.delegate = mockDelegate
        sut.authorizationDelegate = mockAuthorizationDelegate
        
        let didFailExpectation = expectation(description: "didFail should be called")
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as? ApplePayComponent.Error, .invalidToken)
            didFailExpectation.fulfill()
        }
        
        var authorizeCalled = false
        mockAuthorizationDelegate.onAuthorize = { _ in
            authorizeCalled = true
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        }
        
        let mockPayment = PKPaymentMock.create(withPaymentData: Data()) // Empty token
        
        let completionExpectation = expectation(description: "Completion should be called with failure")
        
        // When
        try sut.paymentAuthorizationViewController(
            XCTUnwrap(sut.viewController as? PKPaymentAuthorizationViewController),
            didAuthorizePayment: mockPayment
        ) { result in
            XCTAssertEqual(result.status, .failure)
            completionExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertFalse(authorizeCalled, "didAuthorize should not be called when token is empty")
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
