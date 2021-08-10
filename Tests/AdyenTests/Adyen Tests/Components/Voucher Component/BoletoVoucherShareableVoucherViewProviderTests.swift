//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import XCTest

class BoletoVoucherShareableVoucherViewProviderTests: XCTestCase {

    func testBoletoBancairoVoucher() throws {
        let viewProvider = VoucherShareableViewProvider(
            style: VoucherComponentStyle(),
            environment: Dummy.context.environment
        )

        let boletoDecoded = try Coder.decode(boletoAction) as BoletoVoucherAction
        let action: VoucherAction = .boletoBancairoSantander(boletoDecoded)

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
                        amount: boletoDecoded.totalAmount.value,
                        currencyCode: boletoDecoded.totalAmount.currencyCode
        ))

        let expireyKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date")

        let expireyValueLable: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "30/05/2021")
    }
}
