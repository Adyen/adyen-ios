//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

@MainActor
class VoucherComponentTests: XCTestCase {

    var sut: VoucherComponent!

    var actionPresentationDelegate: ActionPresentationDelegateMock!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    override func setUp() async throws {
        try await super.setUp()
        actionPresentationDelegate = ActionPresentationDelegateMock()
        sut = VoucherComponent(context: Dummy.context)
        sut.configuration.theme = CheckoutTheme(colors: CheckoutColors(primary: .yellow))
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "test_table")
        sut.actionPresentationDelegate = actionPresentationDelegate
    }

    func test_handle_withDokuAction_shouldPresentVoucherViewWithModel() throws {
        let action = try AdyenCoder.decode(dokuIndomaretAction) as VoucherAction

        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            actionPresentationDelegateExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_handle_withEContextATMAction_shouldPresentVoucherViewWithModel() throws {
        let action = try AdyenCoder.decode(econtextATMAction) as VoucherAction
        
        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            actionPresentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_handle_withBoletoAction_shouldPresentVoucherViewWithModel() throws {
        let action = try AdyenCoder.decode(boletoAction) as VoucherAction
        
        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            actionPresentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_handle_withOXXOAction_shouldOfferDownloadAndInstructionsOptions() throws {
        let action = try AdyenCoder.decode(oxxoAction) as VoucherAction
        
        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            self.setupRootViewController(viewController)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            let optionsButton: FormButton! = viewController.view.findView(with: "AdyenActions.VoucherComponent.voucherView.secondaryButton")
            XCTAssertNotNil(optionsButton)
            XCTAssertEqual(optionsButton.title, "More options")
            
            optionsButton.sendActions(for: .touchUpInside)
            
            wait(for: .milliseconds(300))
            
            let alertSheet = try! XCTUnwrap(UIViewController.topPresenter() as? UIAlertController)
            
            let expectedActionTitles = [
                "Copy code",
                "Download PDF",
                "Read instructions",
                "Cancel"
            ]
            
            XCTAssertEqual(alertSheet.actions.map(\.title), expectedActionTitles)
            XCTAssertEqual(alertSheet.actions.count, expectedActionTitles.count)
            
            actionPresentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_handle_withMultibancoAction_shouldOfferSaveAsImageOption() throws {
        let action = try AdyenCoder.decode(multibancoVoucher) as VoucherAction
        
        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            self.setupRootViewController(viewController)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            let optionsButton: FormButton! = viewController.view.findView(with: "AdyenActions.VoucherComponent.voucherView.secondaryButton")
            XCTAssertNotNil(optionsButton)
            XCTAssertEqual(optionsButton.title, "More options")
            
            optionsButton.sendActions(for: .touchUpInside)
            
            let alertSheet = try waitUntilTopPresenter(isOfType: UIAlertController.self)
            
            let expectedActionTitles = [
                "Copy code",
                "Save as image",
                "Cancel"
            ]
            
            XCTAssertEqual(alertSheet.actions.map(\.title), expectedActionTitles)
            XCTAssertEqual(alertSheet.actions.count, expectedActionTitles.count)
            
            actionPresentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test_handle_withEContextStoresAction_shouldPresentVoucherViewWithModel() throws {
        let action = try AdyenCoder.decode(econtextStoresAction) as VoucherAction
        
        let actionPresentationDelegateExpectation = expectation(description: "Expect actionPresentationDelegate.present() to be called.")
        actionPresentationDelegate.doPresent = { [self] viewController in
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            actionPresentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func checkViewModel(
        _ model: VoucherView.Model,
        forAction action: VoucherAction
    ) {
        XCTAssertEqual(model.theme.colors, sut.configuration.theme.colors)
        XCTAssertEqual(model.theme.elements.buttons.primary, sut.configuration.theme.elements.buttons.primary)
        XCTAssertEqual(model.theme.elements.buttons.tertiary, sut.configuration.theme.elements.buttons.tertiary)
        XCTAssertEqual(model.theme.elements.labels.title.font, sut.configuration.theme.elements.labels.title.font)
        XCTAssertEqual(model.theme.elements.labels.title.color, sut.configuration.theme.elements.labels.title.color)
        
        let comps = action.anyAction.totalAmount.formattedComponents
        
        XCTAssertEqual(model.amount, comps.formattedValue)
        XCTAssertEqual(model.currency, comps.formattedCurrencySymbol)
        XCTAssertEqual(
            model.logoUrl,
            LogoURLProvider.logoURL(
                withName: action.anyAction.paymentMethodType.rawValue,
                environment: Dummy.apiContext.environment,
                size: .medium
            )
        )
        XCTAssertEqual(model.mainButtonType == .addToAppleWallet, sut.canAddPasses(action: action.anyAction))
    }
    
}
