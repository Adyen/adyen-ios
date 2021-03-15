//
//  DokuVoucherUITests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/1/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
@testable import AdyenActions
import XCTest

class DokuVoucherUITests: XCTestCase {

    func testDokuIndomaretVoucherCustomLocalization() throws {
        let viewControllerProvider = VoucherViewControllerProvider(style: VoucherComponentStyle())
        viewControllerProvider.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let dokuAction = try Coder.decode(dokuIndomaretAction) as GenericVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let sut = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = sut

        let textLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let instructionButton: UIButton! = sut.view.findView(by: "adyen.dokuVoucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions -- Test")

        let amountLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
                                                                   currencyCode: dokuAction.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date -- Test")

        let expireyValueLable: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name -- Test")

        let shopperNameValueLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwfqwew Gewgewf")

        let merchantKeyLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant -- Test")

        let merchantValueLabel: UILabel! = sut.view.findView(by: "adyen.dokuVoucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

    func testDokuIndomaretVoucher() throws {
        let viewControllerProvider = VoucherViewControllerProvider(style: VoucherComponentStyle())

        let dokuAction = try Coder.decode(dokuIndomaretAction) as GenericVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let viewController = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let textLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let instructionButton: UIButton! = viewController.view.findView(by: "adyen.dokuVoucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions")

        let amountLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
                                                                   currencyCode: dokuAction.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date")

        let expireyValueLable: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name")

        let shopperNameValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwfqwew Gewgewf")

        let merchantKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant")

        let merchantValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

    func testDokuAlfamartVoucher() throws {
        let viewControllerProvider = VoucherViewControllerProvider(style: VoucherComponentStyle())

        let dokuAction = try Coder.decode(dokuAlfamartAction) as GenericVoucherAction
        let action: VoucherAction = .dokuAlfamart(dokuAction)

        let viewController = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let textLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let instructionButton: UIButton! = viewController.view.findView(by: "adyen.dokuVoucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions")

        let amountLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
                                                                   currencyCode: dokuAction.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date")

        let expireyValueLable: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name")

        let shopperNameValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwodihqw Wqodihq")

        let merchantKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant")

        let merchantValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

}
