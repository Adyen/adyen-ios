//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
import PassKit
import XCTest

class ApplePayPaymentTest: XCTestCase {

    func testCreateApplePayPaymentWithSummeryItems() throws {
        _ = try ApplePayPayment(countryCode: "US", currencyCode: "USD", summaryItems: [.init(label: "My Label", amount: 10.5)])
    }

    func testCreateApplePayPaymentWithPayemtn() throws {
        _ = try ApplePayPayment(payment: Payment(amount: Amount(value: 1050, currencyCode: "USD"), countryCode: "US"), brand: "My Label")
    }

    func testInvalidCurrencyCode() {
        // Given
        let amount = Amount(value: 2, unsafeCurrencyCode: "ZZZ")

        // When
        let payment = Payment(amount: amount, countryCode: getRandomCountryCode())

        // Then
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCurrencyCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The currency code is invalid.")
        }

        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: "ZZZ",
            summaryItems: [.init(label: "My Label", amount: 10.5)]
        ))
    }

    func testInvalidCountryCode() {
        // When
        let payment = Payment(amount: Amount(value: 1050, currencyCode: "USD"), unsafeCountryCode: "ZZ")

        // Then
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidCountryCode)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The country code is invalid.")
        }

        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "ZZ",
            currencyCode: "USD",
            summaryItems: [.init(label: "My Label", amount: 10.5)]
        ))
    }

    func testEmptySummaryItems() {
        XCTAssertThrowsError(try ApplePayPayment(countryCode: "US", currencyCode: "USD", summaryItems: [])) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.emptySummaryItems)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The summaryItems array is empty.")
        }
    }

    func testGrandTotalIsNegative() {
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: "USD",
            summaryItems: createInvalidGrandTotalTestSummaryItems()
        )) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.negativeGrandTotal)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "The grand total summary item should be greater than or equal to zero.")
        }
    }

    func testOneItemWithZeroAmount() {
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: "USD",
            summaryItems: createTestSummaryItemsWithZeroAmount()
        )) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            XCTAssertEqual(error as! ApplePayComponent.Error, ApplePayComponent.Error.invalidSummaryItem)
            XCTAssertEqual((error as! ApplePayComponent.Error).localizedDescription, "At least one of the summary items has an invalid amount.")
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
        var items = Dummy.createTestSummaryItems()
        let amount = NSDecimalNumber(mantissa: 0, exponent: 1, isNegative: true)
        let item = PKPaymentSummaryItem(label: "summary_zero_value", amount: amount)
        items.insert(item, at: 0)
        return items
    }
}
