//
//  VoucherViewControllerProviderTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/4/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

class VoucherViewControllerProviderTests: XCTestCase {

    func testCustomLocalization() throws {
        let dokuAction = try Coder.decode(dokuIndomaretAction) as GenericVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let sut = VoucherViewControllerProvider(style: VoucherComponentStyle())
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

    func testCustomUI() throws {
        let dokuAction = try Coder.decode(dokuIndomaretAction) as GenericVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        var style = VoucherComponentStyle()
        style.mainButton.backgroundColor = UIColor.cyan
        style.mainButton.borderColor = UIColor.red
        style.mainButton.borderWidth = 3
        style.mainButton.cornerRounding = .fixed(6)
        style.mainButton.title.color = UIColor.black
        style.mainButton.title.font = .systemFont(ofSize: 23)

        style.secondaryButton.backgroundColor = UIColor.red
        style.secondaryButton.borderColor = UIColor.blue
        style.secondaryButton.borderWidth = 2
        style.secondaryButton.cornerRounding = .fixed(12)
        style.secondaryButton.title.color = UIColor.white
        style.secondaryButton.title.font = .systemFont(ofSize: 34)
        let sut = VoucherViewControllerProvider(style: style)

        let viewController = sut.provide(with: action) as! VoucherViewController

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let saveButton: UIButton! = viewController.view.findView(by: "adyen.voucher.saveButton")
        XCTAssertEqual(saveButton.titleColor(for: .normal), UIColor.white)
        XCTAssertEqual(saveButton.layer.backgroundColor, UIColor.red.cgColor)
        XCTAssertEqual(saveButton.titleLabel?.font, .systemFont(ofSize: 34))
        XCTAssertEqual(saveButton.layer.borderWidth, 2)
        XCTAssertEqual(saveButton.layer.borderColor, UIColor.blue.cgColor)
        XCTAssertEqual(saveButton.layer.cornerRadius, 12)

        let doneButton: UIButton! = viewController.view.findView(by: "adyen.voucher.doneButton")
        XCTAssertEqual(doneButton.titleColor(for: .normal), UIColor.black)
        XCTAssertEqual(doneButton.layer.backgroundColor, UIColor.cyan.cgColor)
        XCTAssertEqual(doneButton.titleLabel?.font, .systemFont(ofSize: 23))
        XCTAssertEqual(doneButton.layer.borderWidth, 3)
        XCTAssertEqual(doneButton.layer.borderColor, UIColor.red.cgColor)
        XCTAssertEqual(doneButton.layer.cornerRadius, 6)
    }

}
