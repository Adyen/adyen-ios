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
        let sut = BalanceChecker()

        // transaction limit > balance
        // amount < balance
        // return true
        let balance1 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.check(balance: balance1, isEnoughToPay: amount1).isBalanceEnough)

        // transaction limit < balance
        // amount < transaction limit
        // return true
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "EUR"))
        let amount2 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.check(balance: balance2, isEnoughToPay: amount2).isBalanceEnough)


        // transaction limit is nil
        // amount < balance
        // return true
        let balance3 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: nil)
        let amount3 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertTrue(try! sut.check(balance: balance3, isEnoughToPay: amount3).isBalanceEnough)

        // transaction limit is nil
        // amount > balance
        // return false
        let balance4 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: nil)
        let amount4 = Payment.Amount(value: 1000, currencyCode: "EUR")
        XCTAssertFalse(try! sut.check(balance: balance4, isEnoughToPay: amount4).isBalanceEnough)


        // transaction limit > balance
        // amount > balance
        // return false
        let balance5 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount5 = Payment.Amount(value: 120, currencyCode: "EUR")
        XCTAssertFalse(try! sut.check(balance: balance5, isEnoughToPay: amount5).isBalanceEnough)

        // transaction limit < balance
        // amount > transaction limit
        // return false
        let balance6 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "EUR"))
        let amount6 = Payment.Amount(value: 120, currencyCode: "EUR")
        XCTAssertFalse(try! sut.check(balance: balance6, isEnoughToPay: amount6).isBalanceEnough)
    }

    func testCurrencyMissmatch() throws {
        let sut = BalanceChecker()

        // transaction limit currency missmatch balance currency
        // amount currency matches balance
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance1 = Balance(availableAmount: .init(value: 100,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "USD"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.check(balance: balance1, isEnoughToPay: amount1), "", {
            XCTAssertEqual(($0 as? BalanceChecker.Error), BalanceChecker.Error.unexpectedCurrencyCode)
        })

        // transaction limit currency missmatch balance currency
        // amount currency matches transaction limit
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 100,
                                                      currencyCode: "USD"))
        let amount2 = Payment.Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.check(balance: balance2, isEnoughToPay: amount2), "", {
            XCTAssertEqual(($0 as? BalanceChecker.Error), BalanceChecker.Error.unexpectedCurrencyCode)
        })


        // transaction limit currency matches balance currency
        // amount currency missmatches
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance3 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount3 = Payment.Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.check(balance: balance3, isEnoughToPay: amount3), "", {
            XCTAssertEqual(($0 as? BalanceChecker.Error), BalanceChecker.Error.unexpectedCurrencyCode)
        })
    }

    func testZeroBalance() throws {
        let sut = BalanceChecker()

        // transaction limit currency missmatch balance currency
        // amount currency matches balance
        // throws BalanceValidator.Error.zeroBalance
        let balance1 = Balance(availableAmount: .init(value: 0,
                                                     currencyCode: "EUR"),
                              transactionLimit: .init(value: 1000,
                                                      currencyCode: "EUR"))
        let amount1 = Payment.Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.check(balance: balance1, isEnoughToPay: amount1), "", {
            XCTAssertEqual(($0 as? BalanceChecker.Error), BalanceChecker.Error.zeroBalance)
        })
    }

}
