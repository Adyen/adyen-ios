//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
import PassKit
import XCTest

class ApplePayComponentTest: XCTestCase {

    var mockDelegate: PaymentComponentDelegateMock!
    var mockApplePayDelegate: ApplePayDelegateMock!
    var sut: ApplePayComponent!
    lazy var amount = Amount(value: 2, currencyCode: "USD")
    lazy var payment = Payment(amount: amount, countryCode: getRandomCountryCode())
    let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: nil)

    private var emptyVC: UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }

    override func setUp() {
        let configuration = ApplePayComponent.Configuration(payment: Dummy.createTestApplePayPayment(),
                                                            merchantIdentifier: "test_id")
        sut = try! ApplePayComponent(paymentMethod: paymentMethod,
                                     context: Dummy.context,
                                     configuration: configuration)
        mockDelegate = PaymentComponentDelegateMock()
        if #available(iOS 15.0, *) {
            mockApplePayDelegate = ApplePayDelegateMockiOS15()
        } else {
            mockApplePayDelegate = ApplePayDelegateMockClassic()
        }
    }

    override func tearDown() {
        sut = nil
        mockDelegate = nil
        UIApplication.shared.keyWindow!.rootViewController?.dismiss(animated: false)
        UIApplication.shared.keyWindow!.rootViewController = emptyVC
    }

    func testApplePayViewControllerShouldCallDelegateDidFail() {
        guard Available.iOS12 else { return }

        // This is necessary to give ApplePay time to disappear from screen.
        wait(for: .seconds(2))

        sut.delegate = mockDelegate
        let viewController = sut!.viewController
        let onDidFailExpectation = expectation(description: "Wait for delegate call")
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            onDidFailExpectation.fulfill()
            self.mockDelegate = nil // to prevent false triggering
        }

        UIApplication.shared.keyWindow!.rootViewController = emptyVC
        UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: false)
        
        wait(for: .seconds(1))
        self.sut.paymentAuthorizationViewControllerDidFinish(viewController as! PKPaymentAuthorizationViewController)

        waitForExpectations(timeout: 10)
        XCTAssertTrue(viewController !== self.sut.viewController)
    }

    func testApplePayViewControllerShouldCallFinalizeCompletion() {
        guard Available.iOS12 else { return }

        // This is necessary to give ApplePay time to disappear from screen.
        wait(for: .seconds(2))

        let viewController = sut!.viewController
        let onDidFinalizeExpectation = expectation(description: "Wait for didFinalize call")

        UIApplication.shared.keyWindow!.rootViewController = emptyVC
        UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: false)
        
        wait(for: .seconds(1))

        sut.finalizeIfNeeded(with: true) {
            onDidFinalizeExpectation.fulfill()
        }
        sut.paymentAuthorizationViewControllerDidFinish(viewController as! PKPaymentAuthorizationViewController)

        waitForExpectations(timeout: 10)
    }

    func testApplePayShipping() {
        guard Available.iOS12 else { return }

        var configuration = ApplePayComponent.Configuration(payment: Dummy.createTestApplePayPayment(),
                                                            merchantIdentifier: "test_id")
        let shippingMethods = [PKShippingMethod(label: "Shipping1", amount: 1.0), PKShippingMethod(label: "Shipping2", amount: 2.0)]
        shippingMethods.forEach { $0.identifier = UUID().uuidString }
        configuration.shippingMethods = shippingMethods

        sut = try! ApplePayComponent(paymentMethod: paymentMethod,
                                     context: Dummy.context,
                                     configuration: configuration)
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

        XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 20000)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 5)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "summary_4")

        sut.paymentAuthorizationViewController(sut!.viewController as! PKPaymentAuthorizationViewController,
                                               didSelect: selectedShippingMethod!) { update in
            XCTAssertEqual(self.mockApplePayDelegate.shippingMethod, shippingMethods.first)
            XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 222200)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 2)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "New Item 2")
            onShippingSelected.fulfill()
        }

        waitForExpectations(timeout: 4)
    }

    func testApplePayShippingContact() {
        guard Available.iOS12 else { return }

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
        contact.name!.givenName = "Test"
        contact.name!.familyName = "Testovich"

        XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 20000)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 5)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "summary_4")
        sut.paymentAuthorizationViewController(sut!.viewController as! PKPaymentAuthorizationViewController,
                                               didSelectShippingContact: contact) { update in

            XCTAssertEqual(self.mockApplePayDelegate.contact, contact)
            XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 222200)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 2)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "New Item 2")
            onContactSelected.fulfill()
        }

        waitForExpectations(timeout: 4)
    }

    @available(iOS 15.0, *)
    func testApplePayCoupon() {
        guard Available.iOS15 else { return }

        sut.applePayDelegate = mockApplePayDelegate
        (mockApplePayDelegate as! ApplePayDelegateMockiOS15).onCouponChange = { coupon, payment in
            .init(paymentSummaryItems: [
                PKPaymentSummaryItem(label: "New Item 1", amount: 1111),
                PKPaymentSummaryItem(label: "New Item 2", amount: 2222)
            ])
        }

        wait(for: .seconds(1))
        let onContactSelected = expectation(description: "Wait for didFinalize call")

        XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 20000)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 5)
        XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "summary_4")
        sut.paymentAuthorizationViewController(sut!.viewController as! PKPaymentAuthorizationViewController,
                                               didChangeCouponCode: "Coupon") { update in

            XCTAssertEqual(self.mockApplePayDelegate.couponCode, "Coupon")
            XCTAssertEqual(self.sut.applePayPayment.amountMinorUnits, 222200)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.count, 2)
            XCTAssertEqual(self.sut.applePayPayment.summaryItems.last!.label, "New Item 2")
            onContactSelected.fulfill()
        }

        waitForExpectations(timeout: 4)
    }

    func testInvalidCurrencyCode() {
        let amount = Amount(value: 2, unsafeCurrencyCode: "ZZZ")
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCurrencyCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The currency code is invalid.")
        }
    }
    
    func testInvalidCountryCode() {
        let payment = Payment(amount: amount, unsafeCountryCode: "ZZ")
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCountryCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The country code is invalid.")
        }
    }
    
    func testEmptySummaryItems() {
        XCTAssertThrowsError(try ApplePayPayment(countryCode: "US", currencyCode: "USD", summaryItems: [])) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.emptySummaryItems)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The summaryItems array is empty.")
        }
    }
    
    func testGrandTotalIsNegative() {
        XCTAssertThrowsError(try ApplePayPayment(countryCode: "US",
                                                 currencyCode: "USD",
                                                 summaryItems: createInvalidGrandTotalTestSummaryItems())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.negativeGrandTotal)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The grand total summary item should be greater than or equal to zero.")
        }
    }
    
    func testOneItemWithZeroAmount() {
        XCTAssertThrowsError(try ApplePayPayment(countryCode: "US",
                                                 currencyCode: "USD",
                                                 summaryItems: createTestSummaryItemsWithZeroAmount())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidSummaryItem)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "At least one of the summary items has an invalid amount.")
        }
    }
    
    func testRequiresModalPresentation() {
        XCTAssertEqual(sut?.requiresModalPresentation, false)
    }
    
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
        var configuration = ApplePayComponent.Configuration(payment: try .init(countryCode: countryCode,
                                                                               currencyCode: currencyCode,
                                                                               summaryItems: expectedSummaryItems),
                                                            merchantIdentifier: "test_id")
        configuration.requiredBillingContactFields = expectedRequiredBillingFields
        configuration.requiredShippingContactFields = expectedRequiredShippingFields
        let paymentRequest = configuration.createPaymentRequest(supportedNetworks: paymentMethod.supportedNetworks)
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
            if #available(iOS 16.0, *) {
                XCTAssertEqual(request.supportedNetworks.count, 0) // For some reason PKPaymentNetwork ignores dankort
            } else {
                XCTAssertEqual(request.supportedNetworks.count, 1)
            }
        }
    }

    func testPaymentRequestViaPayment() throws {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()
        var configuration = ApplePayComponent.Configuration(payment: try .init(payment: payment, brand: "TEST"),
                                                            merchantIdentifier: "test_id")
        configuration.requiredBillingContactFields = expectedRequiredBillingFields
        configuration.requiredShippingContactFields = expectedRequiredShippingFields
        let paymentRequest = configuration.createPaymentRequest(supportedNetworks: paymentMethod.supportedNetworks)

        XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 1)
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "TEST")
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.description, payment.amount.formattedComponents.formattedValue)

        XCTAssertEqual(paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(paymentRequest.currencyCode, amount.currencyCode)
        XCTAssertEqual(paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(paymentRequest.countryCode, payment.countryCode)
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
        XCTAssertEqual(paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
    }

    func testBrandsFiltering() {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: ["mc", "elo", "unknown_network"])
        let supportedNetworks = paymentMethod.supportedNetworks

        if #available(iOS 12.1.1, *) {
            XCTAssertTrue(compareCollections(supportedNetworks, [.masterCard, .elo]))
        } else {
            XCTAssertEqual(supportedNetworks, [.masterCard])
        }
    }

    func testViewWillAppearShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let mockViewController = UIViewController()

        let configuration = ApplePayComponent.Configuration(payment: Dummy.createTestApplePayPayment(),
                                                            merchantIdentifier: "test_id")
        sut = try! ApplePayComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: configuration)

        // When
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }
    
    private func getRandomContactFieldSet() -> Set<PKContactField> {
        let contactFieldsPool: [PKContactField] = [.emailAddress, .name, .phoneNumber, .postalAddress, .phoneticName]
        return contactFieldsPool.randomElement().map { [$0] } ?? []
    }
    
    private func createInvalidGrandTotalTestSummaryItems() -> [PKPaymentSummaryItem] {
        var amounts = (0...3).map { _ in
            NSDecimalNumber(mantissa: UInt64.random(in: 1...20), exponent: 1, isNegative: Bool.random())
        }
        // Negative Grand total
        amounts.append(NSDecimalNumber(mantissa: 20, exponent: 1, isNegative: true))
        return amounts.enumerated().map {
            PKPaymentSummaryItem(label: "summary_\($0)", amount: $1)
        }
    }
    
    private func createTestSummaryItemsWithZeroAmount() -> [PKPaymentSummaryItem] {
        var items = Dummy.createTestSummaryItems()
        let amount = NSDecimalNumber(mantissa: 0, exponent: 1, isNegative: true)
        let item = PKPaymentSummaryItem(label: "summary_zero_value", amount: amount)
        items.insert(item, at: 0)
        return items
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
