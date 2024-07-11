//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class UPIComponentTests: XCTestCase {
    
    func test_init_withApps() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, nil)
    }
    
    func test_init_withoutApps() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, UPIComponent.Constants.vpaFlowIdentifier)
    }

    func test_paymentMethodType_isUpi() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertEqual(sut.paymentMethod.type, .upi)
    }

    func test_shouldRequireModalPresentation() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertTrue(sut.requiresModalPresentation)
    }

    func test_requiresKeyboardInput() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<FormViewController>)
        let childViewController = securedViewController.childViewController

        XCTAssertTrue(childViewController.requiresKeyboardInput)
    }
}
