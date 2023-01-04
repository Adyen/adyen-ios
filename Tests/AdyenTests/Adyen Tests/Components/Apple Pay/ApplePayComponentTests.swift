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
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let configuration = ApplePayComponent.Configuration(summaryItems: createTestSummaryItems(),
                                                            merchantIdentifier: "test_id")
        sut = try! ApplePayComponent(paymentMethod: paymentMethod,
                                     apiContext: Dummy.context,
                                     payment: payment,
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

    func testPaymentMatches() {
        XCTAssertEqual(sut.payment?.countryCode, payment.countryCode)
        XCTAssertEqual(sut.payment?.amount.currencyCode, payment.amount.currencyCode)
        XCTAssertEqual(sut.payment?.amount.value, payment.amount.value)
    }

    func testInvalidCurrencyCode() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let amount = Amount(value: 2, unsafeCurrencyCode: "ZZZ")
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        let configuration = ApplePayComponent.Configuration(summaryItems: createTestSummaryItems(),
                                                            merchantIdentifier: "test_id")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod,
                                                   apiContext: Dummy.context,
                                                   payment: payment,
                                                   configuration: configuration)) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCurrencyCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The currency code is invalid.")
        }
    }
    
    func testInvalidCountryCode() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let payment = Payment(amount: amount, unsafeCountryCode: "ZZ")
        let configuration = ApplePayComponent.Configuration(summaryItems: createTestSummaryItems(),
                                                            merchantIdentifier: "test_id")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod,
                                                   apiContext: Dummy.context,
                                                   payment: payment,
                                                   configuration: configuration)) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCountryCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The country code is invalid.")
        }
    }
    
    func testEmptySummaryItems() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let configuration = ApplePayComponent.Configuration(summaryItems: [],
                                                            merchantIdentifier: "test_id")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod,
                                                   apiContext: Dummy.context,
                                                   payment: payment,
                                                   configuration: configuration)) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.emptySummaryItems)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The summaryItems array is empty.")
        }
    }
    
    func testGrandTotalIsNegative() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let configuration = ApplePayComponent.Configuration(summaryItems: createInvalidGrandTotalTestSummaryItems(),
                                                            merchantIdentifier: "test_id")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod,
                                                   apiContext: Dummy.context,
                                                   payment: payment,
                                                   configuration: configuration)) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.negativeGrandTotal)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The grand total summary item should be greater than or equal to zero.")
        }
    }
    
    func testOneItemWithZeroAmount() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let configuration = ApplePayComponent.Configuration(summaryItems: createTestSummaryItemsWithZeroAmount(),
                                                            merchantIdentifier: "test_id")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod,
                                                   apiContext: Dummy.context,
                                                   payment: payment,
                                                   configuration: configuration)) { error in
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
    
    func testPaymentRequest() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: nil)
        let countryCode = getRandomCountryCode()
        let payment = Payment(amount: amount, countryCode: countryCode)
        let expectedSummaryItems = createTestSummaryItems()
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()
        let configuration = ApplePayComponent.Configuration(summaryItems: expectedSummaryItems,
                                                            merchantIdentifier: "test_id",
                                                            requiredBillingContactFields: expectedRequiredBillingFields,
                                                            requiredShippingContactFields: expectedRequiredShippingFields)
        let paymentRequest = configuration.createPaymentRequest(payment: payment,
                                                                supportedNetworks: paymentMethod.supportedNetworks)
        XCTAssertEqual(paymentRequest.paymentSummaryItems, expectedSummaryItems)
            
        XCTAssertEqual(paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(paymentRequest.supportedNetworks, self.supportedNetworks)
        XCTAssertEqual(paymentRequest.currencyCode, amount.currencyCode)
        XCTAssertEqual(paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(paymentRequest.countryCode, countryCode)
        XCTAssertEqual(paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
        XCTAssertEqual(paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
    }

    func testBrandsFiltering() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name", brands: ["mc", "elo", "unknown_network"])
        let supportedNetworks = paymentMethod.supportedNetworks

        if #available(iOS 12.1.1, *) {
            XCTAssertEqualCollection(supportedNetworks, [.masterCard, .elo])
        } else {
            XCTAssertEqual(supportedNetworks, [.masterCard])
        }
    }

    func testFinalise() {
        let onFinaliseExpectation = expectation(description: "Wait for component to finalise")
        
        sut.finalizeIfNeeded(with: true) {
            onFinaliseExpectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testFinalisePayment() {
        let mockPayment: PKPayment = .init()
        let onApplePayFinaliseExpectation = expectation(description: "Wait for component to finalise")
        sut.paymentAuthorizationViewController(sut.viewController as! PKPaymentAuthorizationViewController,
                                               didAuthorizePayment: mockPayment) { _ in
            onApplePayFinaliseExpectation.fulfill()
        }

        let onFinaliseExpectation = expectation(description: "Wait for component to finalise")
        sut.finalizeIfNeeded(with: true) {
            onFinaliseExpectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testFinaliseOnSuccesfullPayment() {
        let onPaymentProccessedExpectation = expectation(description: "Wait for component to finalise")
        sut.state = .paid { status in
            XCTAssertTrue(status == .success)
            onPaymentProccessedExpectation.fulfill()
        }

        let onFinaliseExpectation = expectation(description: "Wait for component to finalise")
        sut.finalizeIfNeeded(with: true, completion: {
            onFinaliseExpectation.fulfill()
        })

        sut.paymentAuthorizationViewControllerDidFinish(sut.paymentAuthorizationViewController!)

        waitForExpectations(timeout: 10)
    }
    
    private func getRandomContactFieldSet() -> Set<PKContactField> {
        let contactFieldsPool: [PKContactField] = [.emailAddress, .name, .phoneNumber, .postalAddress, .phoneticName]
        return contactFieldsPool.randomElement().map { [$0] } ?? []
    }
    
    private func createTestSummaryItems() -> [PKPaymentSummaryItem] {
        var amounts = (0...3).map { _ in
            NSDecimalNumber(mantissa: UInt64.random(in: 1...20), exponent: 1, isNegative: Bool.random())
        }
        // Positive Grand total
        amounts.append(NSDecimalNumber(mantissa: 20, exponent: 1, isNegative: false))
        return amounts.enumerated().map {
            PKPaymentSummaryItem(label: "summary_\($0)", amount: $1)
        }
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
        var items = createTestSummaryItems()
        let amount = NSDecimalNumber(mantissa: 0, exponent: 1, isNegative: true)
        let item = PKPaymentSummaryItem(label: "summary_zero_value", amount: amount)
        items.insert(item, at: 0)
        return items
    }
    
    private var supportedNetworks: [PKPaymentNetwork] {
        ApplePayPaymentMethod.systemSupportedNetworks
    }
}

extension XCTestCase {

    public func XCTAssertEqualCollection<T>(_ expression1: @autoclosure () throws -> [T],
                                            _ expression2: @autoclosure () throws -> [T],
                                            _ message: @autoclosure () -> String = "",
                                            file: StaticString = #filePath,
                                            line: UInt = #line) where T: Hashable {

        let lhs = try! expression1()
        let rhs = try! expression2()
        if lhs.count != rhs.count { XCTFail("Length must match") }

        let lhsSet = Set<T>(lhs)
        let rhsSet = Set<T>(rhs)
        XCTAssertTrue(lhsSet.intersection(rhsSet).count == lhs.count, message())
    }

}
