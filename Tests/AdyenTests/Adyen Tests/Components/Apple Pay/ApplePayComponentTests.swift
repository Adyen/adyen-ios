//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
import PassKit
import XCTest

class ApplePayComponentTest: XCTestCase {

    var mockDelegate: PaymentComponentDelegateMock!
    var sut: ApplePayComponent!
    lazy var amount = Amount(value: 2, currencyCode: getRandomCurrencyCode())
    lazy var payment = Payment(amount: amount, countryCode: getRandomCountryCode())

    private var emptyVC: UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }

    override func setUp() {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: nil)
        let configuration = ApplePayComponent.Configuration(payment: Dummy.createTestApplePayPayment(),
                                                            merchantIdentifier: "test_id")

        sut = try! ApplePayComponent(paymentMethod: paymentMethod,
                                     apiContext: Dummy.context,
                                     configuration: configuration)
        mockDelegate = PaymentComponentDelegateMock()
        sut.delegate = mockDelegate
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

        let viewController = sut!.viewController
        let onDidFailExpectation = expectation(description: "Wait for delegate call")
        mockDelegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            onDidFailExpectation.fulfill()
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
        mockDelegate.onDidFail = { error, component in
            // TODO: test on Xcode 13.2.1
            // XCTFail("Should not call ComponentError.cancelled")
        }

        UIApplication.shared.keyWindow!.rootViewController = emptyVC
        UIApplication.shared.keyWindow!.rootViewController!.present(viewController, animated: false)
        
        wait(for: .seconds(1))

        sut.finalizeIfNeeded(with: true) {
            onDidFinalizeExpectation.fulfill()
        }
        sut.paymentAuthorizationViewControllerDidFinish(viewController as! PKPaymentAuthorizationViewController)

        waitForExpectations(timeout: 10)
    }

    func testInvalidCurrencyCode() {
        let amount = Amount(value: 2, unsafeCurrencyCode: "ZZZ")
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayPayment(payment: payment)) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCurrencyCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The currency code is invalid.")
        }
    }
    
    func testInvalidCountryCode() {
        let payment = Payment(amount: amount, unsafeCountryCode: "ZZ")
        XCTAssertThrowsError(try ApplePayPayment(payment: payment)) { error in
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
        XCTAssertEqual(paymentRequest.supportedNetworks, self.supportedNetworks)
        XCTAssertEqual(paymentRequest.currencyCode, currencyCode)
        XCTAssertEqual(paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(paymentRequest.countryCode, countryCode)
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
        XCTAssertEqual(paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
    }

    func testPaymentRequestViaPayment() throws {
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: nil)
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()
        var configuration = ApplePayComponent.Configuration(payment: try .init(payment: payment),
                                                            merchantIdentifier: "test_id")
        configuration.requiredBillingContactFields = expectedRequiredBillingFields
        configuration.requiredShippingContactFields = expectedRequiredShippingFields
        let paymentRequest = configuration.createPaymentRequest(supportedNetworks: paymentMethod.supportedNetworks)

        XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 1)
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Total")
        XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.description, payment.amount.formattedComponents.formattedValue)

        XCTAssertEqual(paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(paymentRequest.supportedNetworks, self.supportedNetworks)
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
            XCTAssertEqual(supportedNetworks, [.masterCard, .elo])
        } else {
            XCTAssertEqual(supportedNetworks, [.masterCard])
        }
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
    
    private var supportedNetworks: [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = [
            .visa,
            .masterCard,
            .amex,
            .discover,
            .interac,
            .JCB,
            .suica,
            .quicPay,
            .idCredit,
            .chinaUnionPay
        ]

        if #available(iOS 11.2, *) {
            networks.append(.cartesBancaires)
        }

        if #available(iOS 12.1.1, *) {
            networks.append(.elo)
            networks.append(.mada)
        }

        if #available(iOS 12.0, *) {
            networks.append(.maestro)
            networks.append(.electron)
            networks.append(.vPay)
            networks.append(.eftpos)
        }

        if #available(iOS 14.0, *) {
            networks.append(.girocard)
        }

        if #available(iOS 14.5, *) {
            networks.append(.mir)
        }

        return networks
    }
}
