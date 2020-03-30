//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import XCTest

class StoredPaymentMethodComponentTests: XCTestCase {
    
    func testLocalizationWithCustomTableName() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: "test_type", name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method)
        let payment = Payment(amount: Payment.Amount(value: 34, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, ADYLocalizedString("adyen.cancelButton", sut.localizationParameters))
        XCTAssertEqual(viewController?.actions.last?.title, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let method = StoredPaymentMethodMock(identifier: "id", supportedShopperInteractions: [.shopperNotPresent], type: "test_type", name: "test_name")
        let sut = StoredPaymentMethodComponent(paymentMethod: method)
        let payment = Payment(amount: Payment.Amount(value: 34, currencyCode: "EUR"), countryCode: "DE")
        sut.payment = payment
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let viewController = sut.viewController as? UIAlertController
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.actions.count, 2)
        XCTAssertEqual(viewController?.actions.first?.title, ADYLocalizedString("adyen_cancelButton", sut.localizationParameters))
        XCTAssertEqual(viewController?.actions.last?.title, ADYLocalizedSubmitButtonTitle(with: payment.amount, sut.localizationParameters))
    }
    
}
