//
//  DokuVoucherUITests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/1/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
import Adyen
@testable import AdyenActions

class DokuVoucherUITests: XCTestCase {

    let indomaretJson: [String: Any] = [
        "reference" : "9786512300056485",
        "initialAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "paymentMethodType" : "doku_indomaret",
        "instructionsUrl" : "https://www.doku.com/how-to-pay/indomaret.php",
        "shopperEmail" : "Qwfqwf@POj.co",
        "totalAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "expiresAt" : "2021-02-02T22:00:00",
        "merchantName" : "Adyen Demo Shop",
        "shopperName" : "Qwfqwew Gewgewf",
        "type" : "voucher"
      ]

    let alfamartJson: [String: Any] = [
        "reference" : "8888823200056486",
        "initialAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "paymentMethodType" : "doku_alfamart",
        "instructionsUrl" : "https://www.doku.com/how-to-pay/alfamart.php",
        "shopperEmail" : "Qsosih@oih.com",
        "totalAmount" : [
          "currency" : "IDR",
          "value" : 17408
        ],
        "expiresAt" : "2021-02-02T22:58:00",
        "merchantName" : "Adyen Demo Shop",
        "shopperName" : "Qwodihqw Wqodihq",
        "type" : "voucher"
      ]

    func testDokuIndomaretVoucher() throws {
        let viewControllerProvider = VoucherViewControllerProvider()

        let dokuAction = try Coder.decode(indomaretJson) as DokuVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let viewController = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let titleLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.titleLabel")
        XCTAssertEqual(titleLabel.text, "Amount")

        let subTitleLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.subtitleLabel")
        XCTAssertEqual(subTitleLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
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
        let viewControllerProvider = VoucherViewControllerProvider()

        let dokuAction = try Coder.decode(alfamartJson) as DokuVoucherAction
        let action: VoucherAction = .dokuAlfamart(dokuAction)

        let viewController = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = viewController

        let titleLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.titleLabel")
        XCTAssertEqual(titleLabel.text, "Amount")

        let subTitleLabel: UILabel! = viewController.view.findView(by: "adyen.dokuVoucher.subtitleLabel")
        XCTAssertEqual(subTitleLabel.text, AmountFormatter.formatted(amount: dokuAction.totalAmount.value,
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
