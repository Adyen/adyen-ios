//
//  VoucherViewControllerProviderTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/4/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
import UIKit
import Adyen
@testable import AdyenActions

class VoucherViewControllerProviderTests: XCTestCase {

    func testCustomLocalization() throws {
        let dokuAction = try Coder.decode(dokuIndomaretAction) as DokuVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let sut = VoucherViewControllerProvider()
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost")

        let viewController = sut.provide(with: action) as! VoucherViewController

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let textLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let instructionButton: UIButton! = viewController.view.findView(by: "adyen.dokuVoucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions -- Test")

        let amountLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
                                                                  currencyCode: dokuAction.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date -- Test")

        let expireyValueLable: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name -- Test")

        let shopperNameValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwfqwew Gewgewf")

        let merchantKeyLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant -- Test")

        let merchantValueLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

}
