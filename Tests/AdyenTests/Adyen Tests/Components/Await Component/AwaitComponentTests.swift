//
//  AwaitComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/11/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import XCTest

final class AwaitActionHandlerMock: AnyAwaitActionHandler {

    var delegate: ActionComponentDelegate?

    var onHandle: ((_ action: AwaitAction) -> Void)?

    func handle(_ action: AwaitAction) {
        onHandle?(action)
    }

    var onDidCancel: (() -> Void)?

    func didCancel() {
        onDidCancel?()
    }
}

struct AwaitActionHandlerProviderMock: AnyAwaitActionHandlerProvider {

    var onHandler: (_ paymentMethodType: AwaitPaymentMethod) -> AnyAwaitActionHandler

    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyAwaitActionHandler {
        onHandler(paymentMethodType)
    }

}

extension AwaitAction: Equatable {
    public static func == (lhs: AwaitAction, rhs: AwaitAction) -> Bool {
        lhs.paymentData == rhs.paymentData && lhs.paymentMethodType == rhs.paymentMethodType
    }
}

class AwaitComponentTests: XCTestCase {

    func testLocalizationWithCustomTableName() {

        let sut = AwaitComponent(style: nil)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        let presentationExpectation = expectation(description: "expect presentation delegate to be called")
        presentationDelegate.doPresent = { component in
            let messageLabel: UILabel! = component.viewController.view.findView(by: "messageLabel")
            let spinnerLabel: UILabel! = component.viewController.view.findView(by: "spinnerTitleLabel")

            XCTAssertEqual(messageLabel.text, "Confirm your payment on the MB WAY app -- Test")
            XCTAssertEqual(spinnerLabel.text, "Waiting for confirmation -- Test")

            presentationExpectation.fulfill()
        }

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testRequiresKeyboardInput() {
        let sut = AwaitViewController(viewModel: AwaitComponentViewModel(icon: "icon", message: "message", spinnerTitle: "spinner title"))

        let wrapperViewController = WrapperViewController(child: ModalViewController(rootViewController: sut))

        XCTAssertFalse(wrapperViewController.requiresKeyboardInput)
    }

    func testActionHandling() {
        var style = AwaitComponentStyle()
        style.backgroundColor = UIColor.green
        style.message = TextStyle(font: UIFont.systemFont(ofSize: 15), color: UIColor.red, textAlignment: .center)
        style.spinnerTitle = TextStyle(font: UIFont.systemFont(ofSize: 21), color: UIColor.blue, textAlignment: .left)

        let action = AwaitAction(paymentData: "data", paymentMethodType: .mbway)

        let handlerExpectation = expectation(description: "AwaitActionHandler.handle() must be called.")
        let handlerProvider = AwaitActionHandlerProviderMock { type in

            XCTAssertEqual(type, AwaitPaymentMethod.mbway)

            let handler = AwaitActionHandlerMock()
            handler.onHandle = {
                XCTAssertTrue($0 == action)
                handlerExpectation.fulfill()
            }

            return handler
        }

        let sut = AwaitComponent(awaitComponentBuilder: handlerProvider, style: style)
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let presentationDelegate = PresentationDelegateMock()
        let waitExpectation = expectation(description: "Wait for the presentationDelegate to be called.")
        presentationDelegate.doPresent = { component in
            XCTAssertNotNil(component.viewController as? AwaitViewController)
            let viewController = component.viewController as! AwaitViewController

            UIApplication.shared.keyWindow?.rootViewController = viewController

            let view = viewController.awaitView

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                XCTAssertEqual(view.messageLabel.textColor, UIColor.red)
                XCTAssertEqual(view.messageLabel.textAlignment, .center)
                XCTAssertEqual(view.messageLabel.font, UIFont.systemFont(ofSize: 15))

                XCTAssertEqual(view.spinnerTitleLabel.textColor, UIColor.blue)
                XCTAssertEqual(view.spinnerTitleLabel.textAlignment, .left)
                XCTAssertEqual(view.spinnerTitleLabel.font, UIFont.systemFont(ofSize: 21))
                XCTAssertEqual(view.activityIndicatorView.color, UIColor.blue)

                XCTAssertEqual(view.backgroundColor, .green)

                waitExpectation.fulfill()
            }
        }

        sut.presentationDelegate = presentationDelegate

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }

}
