//
//  BACSActionComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 12/15/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import XCTest

class BACSActionComponentTests: XCTestCase {
    
    func testUI() {
        let style = BACSActionComponentStyle()
        let sut = BACSActionComponent(apiContext: Dummy.context, style: BACSActionComponentStyle())
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        sut.localizationParameters = LocalizationParameters(tableName: "test_table")
        
        presentationDelegate.doPresent = { [self] component in
            XCTAssertNotNil(component.viewController as? ADYViewController)
            let viewController = component.viewController as! ADYViewController
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            wait(for: .seconds(1))
            
            let pdfButton: UIButton? = viewController.view.findView(by: "mainButton")
            let messageLabel: UILabel? = viewController.view.findView(by: "messageLabel")
            let logo: UIImageView? = viewController.view.findView(by: "icon")
            
            // Test pdf button
            XCTAssertEqual(pdfButton?.backgroundColor, style.mainButton.backgroundColor)
            XCTAssertEqual(pdfButton?.layer.cornerRadius, 0)
            
            // Test message label
            XCTAssertEqual(messageLabel?.font, style.messageLabel.font)
            XCTAssertEqual(messageLabel?.textColor, style.messageLabel.color)
            XCTAssertEqual(messageLabel?.textAlignment, style.messageLabel.textAlignment)
            
            // Test logo
            XCTAssertEqual(logo?.layer.cornerRadius, 8)
        }
        
        sut.handle(BACSAction(downloadUrl: URL(string: "www.adyen.com")!, paymentMethodType: .bacs))
        
    }
    
    func testMainSecondaryButtons() {
        let mainButtonExpectation = expectation(description: "Main button tapped")
        
        let delegateMock = ActionViewDelegateMock()
        delegateMock.onMainButtonTap = { _ in
            mainButtonExpectation.fulfill()
        }
        
        let viewModel = BACSActionViewModel(message: "test", imageURL: URL(string: "www.adyen.com")!, buttonTitle: "pdf")
        let style = BACSActionComponentStyle()
        
        let sut = BACSActionView(viewModel: viewModel, style: style)
        sut.delegate = delegateMock
        
        asyncAfterDelay {
            let mainButton: UIButton? = sut.findView(by: "mainButton")
            let messageLabel: UILabel? = sut.findView(by: "messageLabel")
            XCTAssertNotNil(mainButton)
            
            XCTAssertEqual(mainButton?.titleLabel?.text, viewModel.buttonTitle)
            XCTAssertEqual(messageLabel?.text, viewModel.message)
            
            mainButton?.sendActions(for: .touchUpInside)
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
