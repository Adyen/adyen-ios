//
//  BalanceCheckerTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class BalanceCheckerTests: XCTestCase {

    func testHappyScenarios() throws {
        let sut = BalanceChecker()

        // amount < balance < transaction limit
        // return true
        let balance1 = Balance(availableAmount: .init(value: 100,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 1000,
                                                       currencyCode: "EUR"))
        let amount1 = Amount(value: 10, currencyCode: "EUR")
        let result1 = try! sut.check(balance: balance1, isEnoughToPay: amount1)
        XCTAssertEqual(result1.amountToPay, amount1)
        XCTAssertEqual(result1.remainingBalanceAmount, balance1.availableAmount - amount1)
        XCTAssertTrue(try! sut.check(balance: balance1, isEnoughToPay: amount1).isBalanceEnough)

        // amount < transaction limit < balance
        // return true
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount2 = Amount(value: 10, currencyCode: "EUR")
        let result2 = try! sut.check(balance: balance2, isEnoughToPay: amount2)
        XCTAssertEqual(result2.amountToPay, amount2)
        XCTAssertEqual(result2.remainingBalanceAmount, balance2.availableAmount - amount2)
        XCTAssertTrue(try! sut.check(balance: balance2, isEnoughToPay: amount2).isBalanceEnough)

        // transaction limit is nil
        // amount < balance
        // return true
        let balance3 = Balance(availableAmount: .init(value: 100,
                                                      currencyCode: "EUR"),
                               transactionLimit: nil)
        let amount3 = Amount(value: 10, currencyCode: "EUR")
        let result3 = try! sut.check(balance: balance3, isEnoughToPay: amount3)
        XCTAssertEqual(result3.amountToPay, amount3)
        XCTAssertEqual(result3.remainingBalanceAmount, balance3.availableAmount - amount3)
        XCTAssertTrue(try! sut.check(balance: balance3, isEnoughToPay: amount3).isBalanceEnough)

        // transaction limit is nil
        // amount > balance
        // return false
        let balance4 = Balance(availableAmount: .init(value: 100,
                                                      currencyCode: "EUR"),
                               transactionLimit: nil)
        let amount4 = Amount(value: 1000, currencyCode: "EUR")
        let result4 = try! sut.check(balance: balance4, isEnoughToPay: amount4)
        XCTAssertEqual(result4.amountToPay, balance4.availableAmount)
        XCTAssertEqual(result4.remainingBalanceAmount, .init(value: 0, currencyCode: result4.remainingBalanceAmount.currencyCode))
        XCTAssertFalse(try! sut.check(balance: balance4, isEnoughToPay: amount4).isBalanceEnough)

        // balance < amount < transaction limit
        // return false
        let balance5 = Balance(availableAmount: .init(value: 100,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 1000,
                                                       currencyCode: "EUR"))
        let amount5 = Amount(value: 120, currencyCode: "EUR")
        let result5 = try! sut.check(balance: balance5, isEnoughToPay: amount5)
        XCTAssertEqual(result5.amountToPay, balance5.availableAmount)
        XCTAssertEqual(result5.remainingBalanceAmount, .init(value: 0, currencyCode: result5.remainingBalanceAmount.currencyCode))
        XCTAssertFalse(result5.isBalanceEnough)

        // transaction limit < amount < balance
        // return false
        let balance6 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount6 = Amount(value: 120, currencyCode: "EUR")
        let result6 = try! sut.check(balance: balance6, isEnoughToPay: amount6)
        XCTAssertEqual(result6.amountToPay, balance6.transactionLimit)
        XCTAssertFalse(result6.isBalanceEnough)
        XCTAssertEqual(result6.remainingBalanceAmount, balance6.availableAmount - balance6.transactionLimit!)

        // transaction limit < balance < amount
        // return false
        let balance7 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount7 = Amount(value: 1200, currencyCode: "EUR")
        let result7 = try! sut.check(balance: balance7, isEnoughToPay: amount7)
        XCTAssertEqual(result7.amountToPay, balance7.transactionLimit)
        XCTAssertFalse(result7.isBalanceEnough)
        XCTAssertEqual(result7.remainingBalanceAmount, balance7.availableAmount - balance7.transactionLimit!)

        // balance < transaction limit < amount
        // return false
        let balance8 = Balance(availableAmount: .init(value: 100,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 1000,
                                                       currencyCode: "EUR"))
        let amount8 = Amount(value: 1200, currencyCode: "EUR")
        let result8 = try! sut.check(balance: balance8, isEnoughToPay: amount8)
        XCTAssertEqual(result8.amountToPay, balance8.availableAmount)
        XCTAssertEqual(result8.remainingBalanceAmount, .init(value: 0, currencyCode: result5.remainingBalanceAmount.currencyCode))
        XCTAssertFalse(result8.isBalanceEnough)
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
        let amount1 = Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.check(balance: balance1, isEnoughToPay: amount1), "") {
            XCTAssertEqual($0 as? BalanceChecker.Error, BalanceChecker.Error.unexpectedCurrencyCode)
        }

        // transaction limit currency missmatch balance currency
        // amount currency matches transaction limit
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance2 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "USD"))
        let amount2 = Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.check(balance: balance2, isEnoughToPay: amount2), "") {
            XCTAssertEqual($0 as? BalanceChecker.Error, BalanceChecker.Error.unexpectedCurrencyCode)
        }

        // transaction limit currency matches balance currency
        // amount currency missmatches
        // throws BalanceValidator.Error.unexpectedCurrencyCode
        let balance3 = Balance(availableAmount: .init(value: 1000,
                                                      currencyCode: "EUR"),
                               transactionLimit: .init(value: 100,
                                                       currencyCode: "EUR"))
        let amount3 = Amount(value: 10, currencyCode: "USD")
        XCTAssertThrowsError(try sut.check(balance: balance3, isEnoughToPay: amount3), "") {
            XCTAssertEqual($0 as? BalanceChecker.Error, BalanceChecker.Error.unexpectedCurrencyCode)
        }
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
        let amount1 = Amount(value: 10, currencyCode: "EUR")
        XCTAssertThrowsError(try sut.check(balance: balance1, isEnoughToPay: amount1), "") {
            XCTAssertEqual($0 as? BalanceChecker.Error, BalanceChecker.Error.zeroBalance)
        }
    }

}
