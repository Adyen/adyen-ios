//
//  BalanceValidatorTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen

class BalanceValidatorTests: XCTestCase {

    func testHappeyScenarios() throws {
        let sut = BalanceValidator()

        // transaction limit > balance
        // amount < balance
        // return true
        let balance1 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.validate(balance: balance1, toPay: amount1))

        // transaction limit < balance
        // amount < transaction limit
        // return true
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "EUR"))
        let amount2 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.validate(balance: balance2, toPay: amount2))


        // transaction limit is nil
        // amount < balance
        // return true
        let balance3 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: nil)
        let amount3 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.validate(balance: balance3, toPay: amount3))

        // transaction limit is nil
        // amount > balance
        // return false
        let balance4 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: nil)
        let amount4 = Payment.Amount(value: 1000, currencyCode: "EUR")
        XCTAssertFalse(try! sut.validate(balance: balance4, toPay: amount4))


        // transaction limit > balance
        // amount > balance
        // return false
        let balance5 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount5 = Payment.Amount(value: 120, currencyCode: "EUR")
        XCTAssertFalse(try! sut.validate(balance: balance5, toPay: amount5))

        // transaction limit < balance
        // amount > transaction limit
        // return false
        let balance6 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "EUR"))
        let amount6 = Payment.Amount(value: 120, currencyCode: "EUR")
        XCTAssertFalse(try! sut.validate(balance: balance6, toPay: amount6))
    }

    func testCurrencyMissmatch() throws {
        let sut = BalanceValidator()

        // transaction limit currency missmatch balance currency
        // amount currency matches balance
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance1 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "USD"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.validate(balance: balance1, toPay: amount1), "", {
            XCTAssertEqual(($0 as? BalanceValidator.Error), BalanceValidator.Error.unexpectedCurrencyCode)
        })

        // transaction limit currency missmatch balance currency
        // amount currency matches transaction limit
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "USD"))
        let amount2 = Payment.Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.validate(balance: balance2, toPay: amount2), "", {
            XCTAssertEqual(($0 as? BalanceValidator.Error), BalanceValidator.Error.unexpectedCurrencyCode)
        })


        // transaction limit currency matches balance currency
        // amount currency missmatches
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance3 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount3 = Payment.Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.validate(balance: balance3, toPay: amount3), "", {
            XCTAssertEqual(($0 as? BalanceValidator.Error), BalanceValidator.Error.unexpectedCurrencyCode)
        })
    }

    func testZeroBalance() throws {
        let sut = BalanceValidator()

        // transaction limit currency missmatch balance currency
        // amount currency matches balance
        // throws BalanceValidator.Error.zeroBalance
        let balance1 = Balance(availableAmount: .init(value: 0,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.validate(balance: balance1, toPay: amount1), "", {
            XCTAssertEqual(($0 as? BalanceValidator.Error), BalanceValidator.Error.zeroBalance)
        })
    }

}
