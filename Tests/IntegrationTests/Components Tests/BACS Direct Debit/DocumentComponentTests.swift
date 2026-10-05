//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class DocumentComponentTests: XCTestCase {
    
    let action: DocumentAction = .init(downloadUrl: URL(string: "www.adyen.com")!, paymentMethodType: .bacs)
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testUI() throws {
        let theme = CheckoutTheme.default
        let sut = DocumentComponent(context: Dummy.context)
        let actionPresentationDelegate = ActionPresentationDelegateMock()
        sut.actionPresentationDelegate = actionPresentationDelegate
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "test_table")
        
        actionPresentationDelegate.doPresent = { viewController in
            XCTAssertNotNil(viewController as? ActionViewController)
            let viewController = viewController as! ActionViewController
            
            viewController.loadViewIfNeeded()

            let pdfButton: FormButton? = viewController.view.findView(by: "mainButton")
            let messageLabel: UILabel? = viewController.view.findView(by: "messageLabel")
            let logo: UIImageView? = viewController.view.findView(by: "icon")
            
            // Test pdf button
            XCTAssertEqual(pdfButton?.backgroundColor, theme.elements.buttons.tertiary.backgroundColor)
            XCTAssertEqual(pdfButton?.layer.cornerRadius, CGFloat(AdyenUIConstants.defaultCornerRadius))
            
            // Test message label
            XCTAssertEqual(messageLabel?.font, theme.elements.labels.body.font)
            XCTAssertEqual(messageLabel?.textColor, theme.colors.text)
            XCTAssertEqual(messageLabel?.textAlignment, .center)
            
            // Test logo
            XCTAssertEqual(logo?.layer.cornerRadius, CGFloat(AdyenUIConstants.imageCornerRadius))
        }
        
        try sut.handle(DocumentAction(downloadUrl: XCTUnwrap(URL(string: "www.adyen.com")), paymentMethodType: .bacs))
        
    }
    
    func testMainSecondaryButtons() throws {
        let mainButtonExpectation = expectation(description: "Main button tapped")
        
        let delegateMock = DocumentActionViewDelegateMock()
        delegateMock.onMainButtonTap = { _, _ in
            mainButtonExpectation.fulfill()
        }
        
        let viewModel = try DocumentActionViewModel(
            action: action,
            message: "test",
            logoURL: XCTUnwrap(URL(string: "www.adyen.com")),
            buttonTitle: "pdf"
        )
        let sut = DocumentActionView(viewModel: viewModel, theme: .default)
        sut.delegate = delegateMock
        
        let mainButton: FormButton? = sut.findView(by: "mainButton")
        let messageLabel: UILabel? = sut.findView(by: "messageLabel")
        XCTAssertNotNil(mainButton)
        
        XCTAssertEqual(mainButton?.title, viewModel.buttonTitle)
        XCTAssertEqual(messageLabel?.text, viewModel.message)
        
        mainButton?.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
