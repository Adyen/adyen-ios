//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
import PassKit
import XCTest

class ApplePayPaymentTest: XCTestCase {

    func test_initWithSummaryItems_shouldNotThrow() throws {
        XCTAssertNoThrow(try ApplePayPayment(countryCode: "US", currencyCode: "USD", summaryItems: [.init(label: "My Label", amount: 10.5)]))
    }

    func test_initWithPayment_shouldNotThrow() throws {
        XCTAssertNoThrow(try ApplePayPayment(payment: Payment(amount: Amount(value: 1050, currencyCode: "USD"), countryCode: "US"), brand: "My Label"))
    }

    func test_initWithPayment_whenInvalidCurrencyCode_throwsInvalidCurrencyCodeError() {
        // Given
        let invalidCurrencyCode = "ZZZ"

        // When
        let payment = Payment(amount: Amount(value: 2, unsafeCurrencyCode: invalidCurrencyCode), countryCode: "US")

        // Then
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            XCTAssertTrue(error is ApplePayComponent.Error)
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .invalidCurrencyCode)
        }
    }

    func test_initWithSummaryItems_whenInvalidCurrencyCode_throwsInvalidCurrencyCodeError() {
        // Given
        let invalidCurrencyCode = "ZZZ"

        // Then
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: invalidCurrencyCode,
            summaryItems: [.init(label: "My Label", amount: 10.5)]
        )) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .invalidCurrencyCode)
        }
    }

    func test_initWithPayment_whenInvalidCountryCode_throwsInvalidCountryCodeError() {
        // Given
        let invalidCountryCode = "ZZ"

        // When
        let payment = Payment(amount: Amount(value: 1050, currencyCode: "USD"), unsafeCountryCode: invalidCountryCode)

        // Then
        XCTAssertThrowsError(try ApplePayPayment(payment: payment, brand: "TEST")) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .invalidCountryCode)
        }
    }

    func test_initWithSummaryItems_whenInvalidCountryCode_throwsInvalidCountryCodeError() {
        // Given
        let invalidCountryCode = "ZZ"

        // Then
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: invalidCountryCode,
            currencyCode: "USD",
            summaryItems: [.init(label: "My Label", amount: 10.5)]
        )) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .invalidCountryCode)
        }
    }

    func test_init_withEmptySummaryItems_throwsEmptySummaryItemsError() {
        // Given
        let invalidSummeryItems: [PKPaymentSummaryItem] = []

        // Then
        XCTAssertThrowsError(try ApplePayPayment(countryCode: "US", currencyCode: "USD", summaryItems: invalidSummeryItems)) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .emptySummaryItems)
        }
    }

    func test_init_withNegativeGrandTotal_throwsNegativeGrandTotalError() {
        // Given
        let invalidSummeryItems = createInvalidGrandTotalTestSummaryItems()

        // Then
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: "USD",
            summaryItems: invalidSummeryItems
        )) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .negativeGrandTotal)
        }
    }

    func test_init_withZeroAmountSummaryItem_throwsInvalidSummaryItemError() {
        // Given
        let invalidSummeryItems = createTestSummaryItemsWithZeroAmount()

        // Then
        XCTAssertThrowsError(try ApplePayPayment(
            countryCode: "US",
            currencyCode: "USD",
            summaryItems: invalidSummeryItems
        )) { error in
            let applePayError = try? XCTUnwrap(error as? ApplePayComponent.Error)
            XCTAssertEqual(applePayError, .invalidSummaryItem)
        }
    }

    private func createInvalidGrandTotalTestSummaryItems() -> [PKPaymentSummaryItem] {
        var amounts = (0...3).map { _ in
            NSDecimalNumber(mantissa: UInt64.random(in: 1...20), exponent: 1, isNegative: Bool.random())
        }
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
