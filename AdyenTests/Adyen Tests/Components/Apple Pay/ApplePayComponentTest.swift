//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import PassKit
import XCTest

class ApplePayComponentTest: XCTestCase {
    
    func testApplePayViewControllerIsResetAfterDidFinish() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        let sut = try? ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())
        let viewController = sut?.viewController
        
        XCTAssertNotNil(viewController as? PKPaymentAuthorizationViewController)
        sut?.paymentAuthorizationViewControllerDidFinish(viewController as! PKPaymentAuthorizationViewController)
        XCTAssertTrue(viewController !== sut?.viewController)
    }
    
    func testApplePayViewControllerIsResetAfterAuthorization() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        let sut = try? ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())
        let viewController = sut?.viewController
        
        XCTAssertNotNil(viewController as? PKPaymentAuthorizationViewController)
        sut?.paymentAuthorizationViewController(viewController as! PKPaymentAuthorizationViewController, didAuthorizePayment: PKPayment(), completion: { _ in })
        sut?.stopLoading()
        XCTAssertTrue(viewController !== sut?.viewController)
    }
    
    func testInvalidCurrencyCode() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: "wqedf")
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCurrencyCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The currency code is invalid.")
        }
    }
    
    func testInvalidCountryCode() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: "asda")
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCountryCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The country code is invalid.")
        }
    }
    
    func testEmptySummaryItems() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: [])) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.emptySummaryItems)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The summaryItems array is empty.")
        }
    }
    
    func testGrandTotalIsNegative() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createInvalidGrandTotalTestSummaryItems())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.negativeGrandTotal)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The grand total summary item should be greater than or equal to zero.")
        }
    }
    
    func testOneItemWithZeroAmount() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        XCTAssertThrowsError(try ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItemsWithZeroAmount())) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidSummaryItem)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "At least one of the summary items has an invalid amount.")
        }
    }
    
    func testRequiresModalPresentation() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        let sut = try? ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())
        XCTAssertEqual(sut?.requiresModalPresentation, false)
    }
    
    func testPresentationViewControllerValidPayment() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())
        let sut = try? ApplePayComponent(paymentMethod: paymentMethod, payment: payment, merchantIdentifier: "test_id", summaryItems: createTestSummaryItems())
        XCTAssertTrue(sut?.viewController is PKPaymentAuthorizationViewController)
    }
    
    func testPaymentRequest() {
        let paymentMethod = ApplePayPaymentMethod(type: "test_type", name: "test_name")
        let countryCode = getRandomCountryCode()
        let amount = Payment.Amount(value: 2, currencyCode: getRandomCurrencyCode())
        let payment = Payment(amount: amount, countryCode: countryCode)
        let expectedSummaryItems = createTestSummaryItems()
        let expectedRequiredBillingFields = getRandomContactFieldSet()
        let expectedRequiredShippingFields = getRandomContactFieldSet()
        let sut = try? ApplePayComponent(paymentMethod: paymentMethod,
                                         payment: payment,
                                         merchantIdentifier: "test_id",
                                         summaryItems: expectedSummaryItems,
                                         requiredBillingContactFields: expectedRequiredBillingFields,
                                         requiredShippingContactFields: expectedRequiredShippingFields)
        XCTAssertEqual(sut?.paymentRequest.paymentSummaryItems, expectedSummaryItems)
        XCTAssertEqual(sut?.paymentRequest.merchantCapabilities, PKMerchantCapability.capability3DS)
        XCTAssertEqual(sut?.paymentRequest.supportedNetworks, self.supportedNetworks)
        XCTAssertEqual(sut?.paymentRequest.currencyCode, amount.currencyCode)
        XCTAssertEqual(sut?.paymentRequest.merchantIdentifier, "test_id")
        XCTAssertEqual(sut?.paymentRequest.countryCode, countryCode)
        if #available(iOS 11.0, *) {
            XCTAssertEqual(sut?.paymentRequest.requiredBillingContactFields, expectedRequiredBillingFields)
            XCTAssertEqual(sut?.paymentRequest.requiredShippingContactFields, expectedRequiredShippingFields)
        } else {
            XCTAssertEqual(sut?.paymentRequest.requiredBillingAddressFields, nil)
            XCTAssertEqual(sut?.paymentRequest.requiredShippingAddressFields, nil)
        }
    }
    
    private func getRandomCurrencyCode() -> String {
        NSLocale.isoCurrencyCodes.randomElement() ?? "EUR"
    }
    
    private func getRandomCountryCode() -> String {
        NSLocale.isoCountryCodes.randomElement() ?? "DE"
    }
    
    private func getRandomContactFieldSet() -> Set<PKContactField> {
        if #available(iOS 11.0, *) {
            let contactFieldsPool: [PKContactField] = [.emailAddress, .name, .phoneNumber, .postalAddress, .phoneticName]
            return contactFieldsPool.randomElement().map { [$0] } ?? []
        } else {
            return []
        }
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
        var networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover, .interac]
        
        if #available(iOS 12.0, *) {
            networks.append(.maestro)
        }
        
        return networks
    }
}
