//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import UIKit
import XCTest

class EContextStoresVoucherViewControllerProviderTests: XCTestCase {

    func testCustomLocalization() throws {
        let econtextAction = try Coder.decode(econtextStoresAction) as EContextStoresVoucherAction
        let action: VoucherAction = .econtextStores(econtextAction)

        let viewProvider = VoucherShareableViewProvider(
            style: VoucherComponentStyle(),
            environment: Dummy.apiContext.environment
        )
        viewProvider.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost")

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: econtextAction.totalAmount.value,
            currencyCode: econtextAction.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date -- Test")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "02/04/2021")

        let maskedPhoneKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.maskedTelephoneNumberKeyLabel")
        XCTAssertEqual(maskedPhoneKeyLabel.text, "Test-Phone Number")

        let maskedPhoneValueLabel: UILabel! = sut.findView(by: "adyen.voucher.maskedTelephoneNumberValueLabel")
        XCTAssertEqual(maskedPhoneValueLabel.text, "11******89")

    }

}
