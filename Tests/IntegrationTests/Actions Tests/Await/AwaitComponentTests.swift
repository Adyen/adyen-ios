//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import SwiftUI
import XCTest

final class PollingHandlerMock: AnyPollingHandler {
    
    var context: AdyenContext {
        Dummy.context
    }

    var delegate: ActionComponentDelegate?

    var onHandle: ((_ action: PaymentDataAware) -> Void)?

    func handle(_ action: PaymentDataAware) {
        onHandle?(action)
    }

    var onDidCancel: (() -> Void)?

    func didCancel() {
        onDidCancel?()
    }
}

@MainActor
struct AwaitActionHandlerProviderMock: AnyPollingHandlerProvider {

    var onAwaitHandler: ((_ paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler)?
    var onQRHandler: ((_ paymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler)?

    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler {
        onAwaitHandler?(paymentMethodType) ?? PollingHandlerMock()
    }
    
    func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler {
        onQRHandler?(qrPaymentMethodType) ?? PollingHandlerMock()
    }
}

extension AwaitAction: Equatable {
    public static func == (lhs: AwaitAction, rhs: AwaitAction) -> Bool {
        lhs.paymentData == rhs.paymentData && lhs.paymentMethodType == rhs.paymentMethodType
    }
}

@MainActor
class AwaitComponentTests: XCTestCase {

    func testLocalizationWithCustomTableName() {
        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .standard(AwaitAction(paymentData: "data", paymentMethodType: .mbway)),
            actionPresentationDelegate: actionPresentationDelegate,
            configuration: .init(localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)),
            pollingHandlerProvider: PollingHandlerProvider(context: Dummy.context)
        )

        let presentationExpectation = expectation(description: "expect presentation delegate to be called")
        actionPresentationDelegate.doPresent = { viewController in
            let viewModel = try XCTUnwrap(viewController as? UIHostingController<AwaitView>).rootView.viewModel

            XCTAssertEqual(viewModel.title, "Awaiting -- Test")
            XCTAssertEqual(viewModel.description, "Complete the payment in the provider's application or website. -- Test")
            XCTAssertEqual(viewModel.progressTitle, "Awaiting completion… -- Test")

            presentationExpectation.fulfill()
        }

        sut.handle()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testActionHandling() {
        let theme = CheckoutTheme(colors: CheckoutColors(background: .green, text: .red, textSecondary: .blue))

        let action = AwaitAction(paymentData: "data", paymentMethodType: .mbway)

        let handlerExpectation = expectation(description: "AwaitActionHandler.handle() must be called.")
        let handlerProvider = AwaitActionHandlerProviderMock(onAwaitHandler: { type in
            XCTAssertEqual(type, AwaitPaymentMethod.mbway)
                
            let handler = PollingHandlerMock()
            handler.onHandle = {
                XCTAssertTrue($0.paymentData == action.paymentData)
                handlerExpectation.fulfill()
            }
                
            return handler
        }, onQRHandler: nil)

        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let waitExpectation = expectation(description: "Wait for the actionPresentationDelegate to be called.")
        actionPresentationDelegate.doPresent = { viewController in
            let hostingController = try XCTUnwrap(viewController as? UIHostingController<AwaitView>)
            let awaitView = hostingController.rootView

            XCTAssertEqual(hostingController.sizingOptions, .preferredContentSize)
            XCTAssertEqual(awaitView.theme.colors, theme.colors)
            XCTAssertEqual(awaitView.theme.elements.labels.title.font, theme.elements.labels.title.font)
            XCTAssertEqual(awaitView.theme.elements.labels.title.color, theme.elements.labels.title.color)
            XCTAssertEqual(awaitView.theme.elements.labels.body.color, theme.elements.labels.body.color)
            XCTAssertEqual(
                awaitView.viewModel.logoURL,
                LogoURLProvider.logoURL(withName: "mbway", environment: Dummy.context.apiContext.environment)
            )

            waitExpectation.fulfill()
        }

        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .standard(action),
            actionPresentationDelegate: actionPresentationDelegate,
            configuration: .init(
                theme: theme,
                localizationParameters: LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
            ),
            pollingHandlerProvider: handlerProvider
        )

        sut.handle()

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_didCancel_beforeHandle_shouldCancelPollingHandler() {
        let handler = PollingHandlerMock()
        let cancelExpectation = expectation(description: "PollingHandler.didCancel() must be called.")
        handler.onDidCancel = { cancelExpectation.fulfill() }

        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .standard(AwaitAction(paymentData: "data", paymentMethodType: .blik)),
            actionPresentationDelegate: actionPresentationDelegate,
            pollingHandlerProvider: AwaitActionHandlerProviderMock(onAwaitHandler: { _ in handler })
        )

        sut.didCancel()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_handle_whenRedirectFails_shouldFailAndCancelPollingHandler() throws {
        let appLauncher = AppLauncherMock()
        appLauncher.onOpenCustomSchemeUrl = { _, completion in completion?(false) }

        let handler = PollingHandlerMock()
        handler.onHandle = { _ in XCTFail("Polling must not start when the redirect fails.") }
        let cancelExpectation = expectation(description: "PollingHandler.didCancel() must be called.")
        handler.onDidCancel = { cancelExpectation.fulfill() }

        let actionPresentationDelegate = ActionPresentationDelegateMock()
        actionPresentationDelegate.doPresent = { _ in XCTFail("The await screen must not be presented when the redirect fails.") }

        let action = try RedirectableAwaitAction(
            paymentData: "data",
            paymentMethodType: .upiIntent,
            url: XCTUnwrap(URL(string: "upi://pay"))
        )
        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .redirectable(action),
            actionPresentationDelegate: actionPresentationDelegate,
            appLauncher: appLauncher,
            pollingHandlerProvider: AwaitActionHandlerProviderMock(onAwaitHandler: { _ in handler })
        )

        let delegate = ActionComponentDelegateMock()
        let failExpectation = expectation(description: "ActionComponentDelegate.didFail() must be called.")
        delegate.onDidFail = { error, _ in
            XCTAssertEqual(error as? RedirectComponent.Error, .appNotFound)
            failExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_handle_whenPresentationDelegateIsDeallocated_shouldNotStartPolling() throws {
        let handler = PollingHandlerMock()
        handler.onHandle = { _ in XCTFail("Polling must not start without a presentation delegate.") }

        var actionPresentationDelegate: ActionPresentationDelegateMock? = ActionPresentationDelegateMock()
        let sut = try AwaitComponent(
            context: Dummy.context,
            flow: .standard(AwaitAction(paymentData: "data", paymentMethodType: .blik)),
            actionPresentationDelegate: XCTUnwrap(actionPresentationDelegate),
            pollingHandlerProvider: AwaitActionHandlerProviderMock(onAwaitHandler: { _ in handler })
        )
        actionPresentationDelegate = nil

        let assertionExpectation = expectation(description: "Assertion must be triggered.")
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "ActionPresentationDelegate is nil. Provide a presentation delegate to AwaitComponent.")
            assertionExpectation.fulfill()
        }
        defer { AdyenAssertion.listener = nil }

        sut.handle()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_pollingHandlerDidProvide_shouldForwardDataFromAwaitComponent() {
        let handler = PollingHandlerMock()
        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .standard(AwaitAction(paymentData: "data", paymentMethodType: .blik)),
            actionPresentationDelegate: actionPresentationDelegate,
            pollingHandlerProvider: AwaitActionHandlerProviderMock(onAwaitHandler: { _ in handler })
        )

        let delegate = ActionComponentDelegateMock()
        let provideExpectation = expectation(description: "ActionComponentDelegate.didProvide() must be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertEqual(data.paymentData, "data")
            XCTAssertTrue(component === sut)
            provideExpectation.fulfill()
        }
        sut.delegate = delegate

        let data = ActionComponentData(details: AwaitActionDetails(payload: "payload"), paymentData: "data")
        handler.delegate?.didProvide(data, from: handler)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_pollingHandlerDidFail_shouldForwardErrorFromAwaitComponent() {
        let handler = PollingHandlerMock()
        let actionPresentationDelegate = ActionPresentationDelegateMock()
        let sut = AwaitComponent(
            context: Dummy.context,
            flow: .standard(AwaitAction(paymentData: "data", paymentMethodType: .blik)),
            actionPresentationDelegate: actionPresentationDelegate,
            pollingHandlerProvider: AwaitActionHandlerProviderMock(onAwaitHandler: { _ in handler })
        )

        let delegate = ActionComponentDelegateMock()
        let failExpectation = expectation(description: "ActionComponentDelegate.didFail() must be called.")
        delegate.onDidFail = { error, component in
            XCTAssertEqual(error as? Dummy, .error)
            XCTAssertTrue(component === sut)
            failExpectation.fulfill()
        }
        sut.delegate = delegate

        handler.delegate?.didFail(with: Dummy.error, from: handler)

        waitForExpectations(timeout: 2, handler: nil)
    }

}
