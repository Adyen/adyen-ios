//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import XCTest

class BoletoVoucherViewControllerProviderTests: XCTestCase {

    func testBoletoBancairoVoucher() throws {
        let viewControllerProvider = VoucherViewControllerProvider(style: VoucherComponentStyle())

        let boletoDecoded = try Coder.decode(boletoAction) as BoletoVoucherAction
        let action: VoucherAction = .boletoBancairoSantander(boletoDecoded)

        let sut = viewControllerProvider.provide(with: action)

        UIApplication.shared.keyWindow?.rootViewController = sut

        let textLabel: UILabel! = sut.view.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let instructionButton: UIButton! = sut.view.findView(by: "adyen.voucher.instructionButton")
        XCTAssertEqual(instructionButton.titleLabel?.text, "Read instructions")

        let amountLabel: UILabel! = sut.view.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(amount: boletoDecoded.totalAmount.value,
                                                                   currencyCode: boletoDecoded.totalAmount.currencyCode))

        let expireyKeyLabel: UILabel! = sut.view.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date")

        let expireyValueLable: UILabel! = sut.view.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "30/05/2021")
    }
}
