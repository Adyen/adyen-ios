//
//  MultibancoShareableVoucherViewProviderTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 8/27/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class MultibancoShareableVoucherViewProviderTests: XCTestCase {

    func testMultibancoVoucher() throws {
        let viewProvider = VoucherShareableViewProvider(
            style: VoucherComponentStyle(),
            environment: Dummy.apiContext.environment
        )

        let multibancoDecoded = try Coder.decode(multibancoVoucher) as MultibancoVoucherAction
        let action: VoucherAction = .multibanco(multibancoDecoded)

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: multibancoDecoded.totalAmount.value,
            currencyCode: multibancoDecoded.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "30/08/2021")
        
        let shopperReferenceKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperReferenceKeyLabel")
        XCTAssertEqual(shopperReferenceKeyLabel.text, "Shopper Reference")

        let shopperReferenceValueLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperReferenceValueLabel")
        XCTAssertEqual(shopperReferenceValueLabel.text, "Test Order Reference - iOS UIHost")
        
        let entityKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.entityKeyLabel")
        XCTAssertEqual(entityKeyLabel.text, "Entity")

        let entityValueLabel: UILabel! = sut.findView(by: "adyen.voucher.entityValueLabel")
        XCTAssertEqual(entityValueLabel.text, "11249")
    }

}
