//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

class EContextATMShareableVoucherViewProviderTests: XCTestCase {

    func testCustomLocalization() throws {
        let econtextAction = try Coder.decode(econtextATMAction) as EContextATMVoucherAction
        let action: VoucherAction = .econtextATM(econtextAction)

        let viewProvider = VoucherShareableViewProvider(
            style: VoucherComponentStyle(),
            environment: Dummy.context.environment
        )
        viewProvider.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost")

        let sut = viewProvider.provideView(with: action)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
                        amount: econtextAction.totalAmount.value,
                        currencyCode: econtextAction.totalAmount.currencyCode
        ))

        let collectionInstitutionKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.CollectionInstitutionNumberKeyLabel")
        XCTAssertEqual(collectionInstitutionKeyLabel.text, "Collection Institution Number -- Test")

        let collectionInstitutionValueLable: UILabel! = sut.findView(by: "adyen.voucher.CollectionInstitutionNumberValueLabel")
        XCTAssertEqual(collectionInstitutionValueLable.text, "58091")

        let expireyKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expireyKeyLabel.text, "Expiration Date -- Test")

        let expireyValueLable: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expireyValueLable.text, "02/04/2021")

        let maskedPhoneKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.maskedTelephoneNumberKeyLabel")
        XCTAssertEqual(maskedPhoneKeyLabel.text, "Test-Phone Number")

        let maskedPhoneValueLabel: UILabel! = sut.findView(by: "adyen.voucher.maskedTelephoneNumberValueLabel")
        XCTAssertEqual(maskedPhoneValueLabel.text, "11******89")

    }
    
}
