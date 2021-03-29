//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

class EContextStoresVoucherViewControllerProviderTests: XCTestCase {

    func testCustomLocalization() throws {
        let econtextAction = try Coder.decode(econtextStoresAction) as EContextStoresVoucherAction
        let action: VoucherAction = .econtextStores(econtextAction)

        let sut = VoucherViewControllerProvider(style: VoucherComponentStyle())
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost")

        let viewController = sut.provide(with: action) as! VoucherViewController

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let textLabel: UILabel! = viewController.view.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let instructionButton: UIButton! = viewController.view.findView(by: "adyen.voucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions -- Test")

        let amountLabel: UILabel! = viewController.view.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: econtextAction.totalAmount.value,
                                                                   currencyCode: econtextAction.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = viewController.view.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date -- Test")

        let expireyValueLable: UILabel! = viewController.view.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/04/2021")

        let maskedPhoneKeyLabel: UILabel! = viewController.view.findView(by: "adyen.voucher.maskedTelephoneNumberKeyLabel")
        XCTAssertEqual(maskedPhoneKeyLabel.text, "Test-Phone Number")

        let maskedPhoneValueLabel: UILabel! = viewController.view.findView(by: "adyen.voucher.maskedTelephoneNumberValueLabel")
        XCTAssertEqual(maskedPhoneValueLabel.text, "11******89")

    }

    func testCustomUI() throws {
        let econtextAction = try Coder.decode(econtextStoresAction) as EContextStoresVoucherAction
        let action: VoucherAction = .econtextStores(econtextAction)

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
