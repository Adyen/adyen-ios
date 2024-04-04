//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
import AdyenNetworking
import SafariServices
import XCTest

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

    func testUIConfiguration() {
        let action = RedirectAction(url: URL(string: "https://adyen.com")!, paymentData: "data")
        let style = RedirectComponentStyle(preferredBarTintColor: UIColor.red,
                                           preferredControlTintColor: UIColor.black,
                                           modalPresentationStyle: .fullScreen)
        let sut = BrowserComponent(url: action.url, context: Dummy.context,
                                   style: style)
        XCTAssertNotNil(sut.viewController as? SFSafariViewController)
        XCTAssertEqual(sut.viewController.modalPresentationStyle, .fullScreen)
        XCTAssertEqual((sut.viewController as! SFSafariViewController).preferredBarTintColor, UIColor.red)
        XCTAssertEqual((sut.viewController as! SFSafariViewController).preferredControlTintColor, UIColor.black)
    }
    
    func testOpenCustomSchemeSuccess() {
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
        
        let action = RedirectAction(url: URL(string: "bla://")!, paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenCustomSchemeFailure() {
        let sut = RedirectComponent(context: Dummy.context)
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
        
        delegate.onDidFail = { error, component in
            XCTAssertTrue(error is RedirectComponent.Error)
            XCTAssertEqual(error as! RedirectComponent.Error, RedirectComponent.Error.appNotFound)
            XCTAssertTrue(component === sut)
        }
        
        let action = RedirectAction(url: URL(string: "bla://")!, paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenUniversalLinkSuccess() {
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
        
        let action = RedirectAction(url: URL(string: "https://maps.apple.com")!, paymentData: "test_data")
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
        
        let action = RedirectAction(url: URL(string: "https://maps.apple.com")!, paymentData: "test_data")
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

        let action = RedirectAction(url: URL(string: "https://www.adyen.com?returnUrlQueryString=anything")!, paymentData: "test_data")
        sut.handle(action)
        
        try waitUntilTopPresenter(isOfType: SFSafariViewController.self)
    }

    func testOpenHttpWebLinkAndDragedDown() throws {
        let sut = RedirectComponent(context: Dummy.context)
        sut.presentationDelegate = try UIViewController.topPresenter()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")
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

    func testRedirectResult() {
        // Given
        let sut = RedirectComponent(context: Dummy.context)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")

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
        XCTAssertTrue(RedirectComponent.applicationDidOpen(from: URL(string: "https://www.adyen.com?redirectResult=XXX")!))

        // Then
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNativeRedirectHappyScenario() {
        let apiClient = APIClientMock()
        let sut = RedirectComponent(context: Dummy.context, apiClient: apiClient.retryAPIClient(with: SimpleScheduler(maximumCount: 2)))
        apiClient.mockedResults = [.success(try! RedirectDetails(returnURL: URL(string: "url://?redirectResult=test_redirectResult")!))]
        
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
        
        let action = RedirectAction(url: URL(string: "https://google.com")!, paymentData: nil, nativeRedirectData: "test_nativeRedirectData")
        sut.handle(action)
        XCTAssertTrue(RedirectComponent.applicationDidOpen(from: URL(string: "url://?queryParam=value")!))
        
        waitForExpectations(timeout: 10)
    }
    
    func testNativeRedirectReturnUrlMissingQueryParameters() {
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
        
        let action = RedirectAction(url: URL(string: "https://google.com")!, paymentData: nil, nativeRedirectData: "test_nativeRedirectData")
        sut.handle(action)
        XCTAssertFalse(RedirectComponent.applicationDidOpen(from: URL(string: "url://")!))
        
        waitForExpectations(timeout: 10)
    }
    
    func testNativeRedirectEndpointCallFails() {
        let apiClient = APIClientMock()
        let sut = RedirectComponent(context: Dummy.context, apiClient: apiClient.retryAPIClient(with: SimpleScheduler(maximumCount: 2)))
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
            XCTAssertEqual(error as! Dummy, .error)
            redirectExpectation.fulfill()
        }
        
        let action = RedirectAction(url: URL(string: "https://google.com")!, paymentData: nil, nativeRedirectData: "test_nativeRedirectData")
        sut.handle(action)
        XCTAssertTrue(RedirectComponent.applicationDidOpen(from: URL(string: "url://?queryParam=value")!))
        
        waitForExpectations(timeout: 10)
    }
}
