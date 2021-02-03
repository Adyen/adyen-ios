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

    func testDokuIndomaretVoucher() throws {
        let viewControllerProvider = VoucherViewControllerProvider()

        let dokuAction = try Coder.decode(dokuIndomaretAction) as DokuVoucherAction
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

        let dokuAction = try Coder.decode(dokuAlfamartAction) as DokuVoucherAction
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
