//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class DokuVoucherUITests: XCTestCase {

    func testDokuIndomaretVoucherCustomLocalization() throws {
        let viewControllerProvider = VoucherShareableViewProvider(style: VoucherComponentStyle(), environment: Dummy.apiContext.environment)
        viewControllerProvider.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let dokuAction = try Coder.decode(dokuIndomaretAction) as DokuVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let sut = viewControllerProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment. -- Test")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: dokuAction.totalAmount.value,
            currencyCode: dokuAction.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date -- Test")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name -- Test")

        let shopperNameValueLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwfqwew Gewgewf")

        let merchantKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant -- Test")

        let merchantValueLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

    func testDokuIndomaretVoucher() throws {
        let viewProvider = VoucherShareableViewProvider(style: VoucherComponentStyle(), environment: Dummy.apiContext.environment)

        let dokuAction = try Coder.decode(dokuIndomaretAction) as DokuVoucherAction
        let action: VoucherAction = .dokuIndomaret(dokuAction)

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: dokuAction.totalAmount.value,
            currencyCode: dokuAction.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name")

        let shopperNameValueLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwfqwew Gewgewf")

        let merchantKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant")

        let merchantValueLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

    func testDokuAlfamartVoucher() throws {
        let viewProvider = VoucherShareableViewProvider(style: VoucherComponentStyle(), environment: Dummy.apiContext.environment)

        let dokuAction = try Coder.decode(dokuAlfamartAction) as DokuVoucherAction
        let action: VoucherAction = .dokuAlfamart(dokuAction)

        let sut = viewProvider.provideView(with: action, logo: nil)

        UIApplication.shared.keyWindow?.rootViewController?.view = sut

        let textLabel: UILabel! = sut.findView(by: "adyen.voucher.textLabel")
        XCTAssertEqual(textLabel.text, "Thank you for your purchase, please use the following information to complete your payment.")

        let amountLabel: UILabel! = sut.findView(by: "adyen.voucher.amountLabel")
        XCTAssertEqual(amountLabel.text, AmountFormatter.formatted(
            amount: dokuAction.totalAmount.value,
            currencyCode: dokuAction.totalAmount.currencyCode
        ))

        let expiryKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationKeyLabel")
        XCTAssertEqual(expiryKeyLabel.text, "Expiration Date")

        let expiryValueLabel: UILabel! = sut.findView(by: "adyen.voucher.expirationValueLabel")
        XCTAssertEqual(expiryValueLabel.text, "02/02/2021")

        let shopperNameKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameKeyLabel")
        XCTAssertEqual(shopperNameKeyLabel.text, "Shopper Name")

        let shopperNameValueLabel: UILabel! = sut.findView(by: "adyen.voucher.shopperNameValueLabel")
        XCTAssertEqual(shopperNameValueLabel.text, "Qwodihqw Wqodihq")

        let merchantKeyLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantKeyLabel")
        XCTAssertEqual(merchantKeyLabel.text, "Merchant")

        let merchantValueLabel: UILabel! = sut.findView(by: "adyen.voucher.merchantValueLabel")
        XCTAssertEqual(merchantValueLabel.text, "Adyen Demo Shop")
    }

}
