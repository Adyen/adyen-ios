//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import AdyenDropIn

class PaymentMethodListComponentTests: XCTestCase {

    func testLocalization() {
        let method1 = PaymentMethodMock(type: "test_stored_type_1", name: "test_stored_name_1")
        let method2 = PaymentMethodMock(type: "test_stored_type_2", name: "test_stored_name_2")
        let storedComponent = PaymentComponentMock(paymentMethod: method1)
        let regularComponent = PaymentComponentMock(paymentMethod: method2)
        let sectionedComponents = SectionedComponents(stored: [storedComponent], regular: [regularComponent])
        let sut = PaymentMethodListComponent(components: sectionedComponents)
        sut.localizationTable = "AdyenUIHost"

        let listViewController = sut.listViewController
        XCTAssertEqual(listViewController.title, ADYLocalizedString("adyen.paymentMethods.title", "AdyenUIHost"))
        XCTAssertEqual(listViewController.sections.count, 2)
        XCTAssertEqual(listViewController.sections[1].title, ADYLocalizedString("adyen.paymentMethods.otherMethods",
        "AdyenUIHost"))
    }

}
