//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

class VoucherComponentTests: XCTestCase {

    var sut: VoucherComponent!

    var presentationDelegate: PresentationDelegateMock!

    override func setUp() {
        super.setUp()
        presentationDelegate = PresentationDelegateMock()
        sut = VoucherComponent(apiContext: Dummy.context, style: nil)
        sut.localizationParameters = LocalizationParameters(tableName: "test_table")
        sut.presentationDelegate = presentationDelegate
    }

    func testDokuVoucherComponent() throws {
        let action = try Coder.decode(dokuIndomaretAction) as VoucherAction

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testEContextATMVoucherComponent() throws {
        let action = try Coder.decode(econtextATMAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testBoletoVoucherComponent() throws {
        let action = try Coder.decode(boletoAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testOXXOVoucherComponent() throws {
        let action = try Coder.decode(oxxoAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testEContextStoresVoucherComponent() throws {
        let action = try Coder.decode(econtextStoresAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func checkViewModel(
        _ model: VoucherView.Model,
        forAction action: VoucherAction
    ) {
        XCTAssertEqual(model.style.mainButton, sut.style.mainButton)
        XCTAssertEqual(model.style.secondaryButton, sut.style.secondaryButton)
        XCTAssertEqual(model.style.amountLabel, sut.style.amountLabel)
        XCTAssertEqual(model.style.currencyLabel, sut.style.currencyLabel)
        XCTAssertEqual(model.style.codeConfirmationColor, sut.style.codeConfirmationColor)
        XCTAssertEqual(model.style.backgroundColor, sut.style.backgroundColor)
        
        let comps = action.anyAction.totalAmount.formattedComponents
        
        XCTAssertEqual(model.amount, comps.formattedValue)
        XCTAssertEqual(model.currency, comps.formattedCurrencySymbol)
        XCTAssertEqual(
            model.logoUrl,
            LogoURLProvider.logoURL(
                withName: action.anyAction.paymentMethodType.rawValue,
                environment: Dummy.context.environment,
                size: .medium
            )
        )
        XCTAssertEqual(model.mainButtonType == .addToAppleWallet, sut.canAddPasses)
    }
    
}
