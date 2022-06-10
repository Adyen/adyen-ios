//
//  OXXOShareableVoucherViewProviderTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 8/11/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class OXXOShareableVoucherViewProviderTests: XCTestCase {

    func testOXXOVoucher() throws {
        let viewProvider = VoucherShareableViewProvider(
            style: VoucherComponentStyle(),
            environment: Dummy.apiContext.environment
        )

        let oxxoDecoded = try Coder.decode(oxxoAction) as OXXOVoucherAction
        let action: VoucherAction = .oxxo(oxxoDecoded)

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: oxxoDecoded.totalAmount.value,
            currencyCode: oxxoDecoded.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "15/08/2021")
        
        let shopperReferenceKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperReferenceKeyLabel")
        XCTAssertEqual(shopperReferenceKeyLabel.text, "Shopper Reference")

        let shopperReferenceValueLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperReferenceValueLabel")
        XCTAssertEqual(shopperReferenceValueLabel.text, "Test Order Reference - iOS UIHost")
        
        let alternativeReferenceKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.alternativeReferenceKeyLabel")
        XCTAssertEqual(alternativeReferenceKeyLabel.text, "Alternative Reference")

        let alternativeReferenceValueLabel: UILabel! = sut.findView(by: "adyen.voucher.alternativeReferenceValueLabel")
        XCTAssertEqual(alternativeReferenceValueLabel.text, "59168675976701")
    }

}
