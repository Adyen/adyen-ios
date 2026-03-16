//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import AdyenNetworking
import SafariServices
import XCTest

@MainActor
class RedirectComponentTests: XCTestCase {
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.dismiss(animated: false) {
            super.setUp(completion: completion)
        }
    }
    
    override func tearDown(completion: @escaping (Error?) -> Void) {
        UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.dismiss(animated: false) {
            super.tearDown(completion: completion)
        }
    }

    func testUIConfiguration() throws {
        // SFSafariViewController.preferredBarTintColor and preferredControlTintColor are deprecated
        // and return nil on iOS 26.0+, making this test non-functional
        if #available(iOS 26.0, *) {
            throw XCTSkip("SFSafariViewController color customization APIs are deprecated on iOS 26.0+")
        }

        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://adyen.com")), paymentData: "data")
        let style = RedirectComponentStyle(
            preferredBarTintColor: UIColor.red,
            preferredControlTintColor: UIColor.black,
            modalPresentationStyle: .fullScreen
        )
        let sut = BrowserComponent(
            url: action.url,
            context: Dummy.context,
            style: style
        )
        XCTAssertNotNil(sut.viewController as? SFSafariViewController)
        XCTAssertEqual(sut.viewController.modalPresentationStyle, .fullScreen)
        XCTAssertEqual((sut.viewController as? SFSafariViewController)?.preferredBarTintColor, UIColor.red)
        XCTAssertEqual((sut.viewController as? SFSafariViewController)?.preferredControlTintColor, UIColor.black)
    }
    
    func testOpenCustomSchemeSuccess() throws {
        let sut = RedirectComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openCustomSchemeUrl() to be called")
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "bla://")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTFail("appLauncher.openUniversalAppUrl() must not to be called")
        }
        
        let delegateExpectation = expectation(description: "Expect delegate.didOpenExternalApplication() to be called")
        delegate.onDidOpenExternalApplication = {
            XCTAssertTrue($0 === sut)
            delegateExpectation.fulfill()
        }
        
        let action = try RedirectAction(url: XCTUnwrap(URL(string: "bla://")), paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenCustomSchemeFailure() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = RedirectComponent(context: Dummy.context(with: analyticsProviderMock))
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openCustomSchemeUrl() to be called")
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "bla://")!)
            completion?(false)
            appLauncherExpectation.fulfill()
        }
        
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTFail("appLauncher.openUniversalAppUrl() must not to be called")
        }
        
        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }
        
        let testPaymentMethodName = "testRedirectPaymentMethod"
        delegate.onDidFail = { error, component in
            let errorEvent = analyticsProviderMock.errors[0]
            XCTAssertEqual(errorEvent.errorType, .redirect)
            XCTAssertEqual(errorEvent.component, testPaymentMethodName)
            XCTAssertEqual(
                errorEvent.code,
                AnalyticsConstants.ErrorCode.redirectFailed.stringValue
            )
            XCTAssertTrue(error is RedirectComponent.Error)
            XCTAssertEqual(error as! RedirectComponent.Error, RedirectComponent.Error.appNotFound)
            XCTAssertTrue(component === sut)
        }
        
        let action = try RedirectAction(url: XCTUnwrap(URL(string: "bla://")), paymentData: "test_data", paymentMethodType: testPaymentMethodName)
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenUniversalLinkSuccess() throws {
        let sut = RedirectComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://maps.apple.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        let delegateExpectation = expectation(description: "Expect delegate.didOpenExternalApplication() to be called")
        delegate.onDidOpenExternalApplication = {
            XCTAssertTrue($0 === sut)
            delegateExpectation.fulfill()
        }
        
        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://maps.apple.com")), paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenUniversalLinkFailure() throws {
        let sut = RedirectComponent(context: Dummy.context)
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        let presentingViewControllerMock = PresentingViewControllerMock()
        sut.presentationDelegate = presentingViewControllerMock
        let topViewController = try UIViewController.topPresenter()
        topViewController.present(presentingViewControllerMock, animated: false, completion: nil)
        
        let safariVCExpectation = expectation(description: "Expect SFSafariViewController() to be presented")
        presentingViewControllerMock.onPresent = { viewController, animated, completion in
            XCTAssertTrue(viewController is SFSafariViewController)
            completion?()
            safariVCExpectation.fulfill()
        }
        
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://maps.apple.com")!)
            completion?(false)
            appLauncherExpectation.fulfill()
        }
        
        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }
        
        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://maps.apple.com")), paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testOpenHttpWebLink() throws {
        let sut = RedirectComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher

        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }

        appLauncher.onOpenUniversalAppUrl = { url, completion in
            completion?(false)
        }

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com?returnUrlQueryString=anything")), paymentData: "test_data")
        sut.handle(action)
        
        try waitUntilTopPresenter(isOfType: SFSafariViewController.self)
    }

    func testOpenHttpWebLinkAndDragedDown() throws {
        let sut = RedirectComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "test_data")
        sut.handle(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")

        delegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            waitExpectation.fulfill()
        }

        let topPresentedViewController = try waitUntilTopPresenter(isOfType: SFSafariViewController.self)

        let presentationController = try XCTUnwrap(topPresentedViewController.presentationController)
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRedirectResult() throws {
        // Given
        let sut = RedirectComponent(context: Dummy.context)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let action = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "test_data")

        let presentExpectation = expectation(description: "Expect in app browser to be presented")
        presentationDelegate.doPresent = { component in
            presentExpectation.fulfill()
        }

        let redirectExpectation = expectation(description: "Expect redirect to be proccessed")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.details)
            redirectExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in XCTFail("Should not call onDidFail") }

        // When
        // action handled
        sut.handle(action)
        wait(for: .seconds(1))

        // and redirect received
        XCTAssertTrue(try RedirectComponent.applicationDidOpen(from: XCTUnwrap(URL(string: "https://www.adyen.com?redirectResult=XXX"))))

        // Then
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNativeRedirectHappyScenario() throws {
        let apiClient = APIClientMock()
        let sut = RedirectComponent(context: Dummy.context)
        sut.apiClient = apiClient
        apiClient.mockedResults = try [.success(RedirectDetails(returnURL: XCTUnwrap(URL(string: "url://?redirectResult=test_redirectResult"))))]
        
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://google.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let redirectExpectation = expectation(description: "Expect redirect to be proccessed")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.details)
            redirectExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in XCTFail("Should not call onDidFail") }
        
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: nil,
            type: .nativeRedirect,
            nativeRedirectData: "test_nativeRedirectData"
        )
        sut.handle(action)
        XCTAssertTrue(try RedirectComponent.applicationDidOpen(from: XCTUnwrap(URL(string: "url://?queryParam=value"))))
        
        waitForExpectations(timeout: 10)
    }
    
    func testNativeRedirectReturnUrlMissingQueryParameters() throws {
        let sut = RedirectComponent(context: Dummy.context)
        
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://google.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        delegate.onDidProvide = { data, component in
            XCTFail("Should not call onDidProvide")
        }
        delegate.onDidFail = { error, _ in
            XCTFail("Should not call onDidProvide")
        }
        
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: nil,
            type: .nativeRedirect,
            nativeRedirectData: "test_nativeRedirectData"
        )
        sut.handle(action)
        XCTAssertFalse(try RedirectComponent.applicationDidOpen(from: XCTUnwrap(URL(string: "url://"))))
        
        waitForExpectations(timeout: 10)
    }
    
    func testNativeRedirectEndpointCallFails() throws {
        let apiClient = APIClientMock()
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = RedirectComponent(context: Dummy.context(with: analyticsProviderMock))
        sut.apiClient = apiClient
        apiClient.mockedResults = [.failure(Dummy.error)]
        
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://google.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let redirectExpectation = expectation(description: "Expect redirect to be NOT handled by RedirectComponent")
        delegate.onDidProvide = { data, component in
            XCTFail("Should not call onDidProvide")
        }
        delegate.onDidFail = { error, _ in
            let errorEvent = analyticsProviderMock.errors[0]
            XCTAssertEqual(errorEvent.errorType, .api)
            XCTAssertEqual(errorEvent.component, "redirect")
            XCTAssertEqual(
                errorEvent.code,
                AnalyticsConstants.ErrorCode.apiErrorNativeRedirect.stringValue
            )
            XCTAssertEqual(error as! Dummy, .error)
            redirectExpectation.fulfill()
        }
        
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: nil,
            type: .nativeRedirect,
            nativeRedirectData: "test_nativeRedirectData"
        )
        sut.handle(action)
        XCTAssertTrue(try RedirectComponent.applicationDidOpen(from: XCTUnwrap(URL(string: "url://?queryParam=value"))))
        
        waitForExpectations(timeout: 10)
    }

    func testNativeRedirectWithNativeRedirectDataNilShouldPerformNativeRedirectResultRequest() throws {
        // Given
        let apiClient = APIClientMock()
        let sut = RedirectComponent(context: Dummy.context)
        sut.apiClient = apiClient
        apiClient.mockedResults = try [.success(RedirectDetails(returnURL: XCTUnwrap(URL(string: "url://?redirectResult=test_redirectResult"))))]

        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "https://google.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }

        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let redirectExpectation = expectation(description: "Expect redirect to be proccessed")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.details)
            redirectExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in XCTFail("Should not call onDidFail") }

        // When
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: nil,
            type: .nativeRedirect,
            nativeRedirectData: nil
        )
        sut.handle(action)

        // Then
        XCTAssertTrue(try RedirectComponent.applicationDidOpen(from: XCTUnwrap(URL(string: "url://?queryParam=value"))))
        waitForExpectations(timeout: 10)
    }
}
