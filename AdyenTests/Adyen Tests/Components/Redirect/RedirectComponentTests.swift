//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import SafariServices
import XCTest

class RedirectComponentTests: XCTestCase {
    
    func testOpenCustomSchemeSuccess() {
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.universalRedirectComponent.appLauncher = appLauncher
        
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
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.universalRedirectComponent.appLauncher = appLauncher
        
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
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.universalRedirectComponent.appLauncher = appLauncher
        
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "http://maps.apple.com")!)
            completion?(true)
            appLauncherExpectation.fulfill()
        }
        
        let delegateExpectation = expectation(description: "Expect delegate.didOpenExternalApplication() to be called")
        delegate.onDidOpenExternalApplication = {
            XCTAssertTrue($0 === sut)
            delegateExpectation.fulfill()
        }
        
        let action = RedirectAction(url: URL(string: "http://maps.apple.com")!, paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testOpenUniversalLinkFailure() {
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.universalRedirectComponent.appLauncher = appLauncher
        let presentingViewControllerMock = PresentingViewControllerMock()
        let topViewController: UIViewController! = UIApplication.shared.keyWindow?.rootViewController?.adyen.topPresenter
        
        topViewController.present(presentingViewControllerMock, animated: false, completion: nil)
        
        let safariVCExpectation = expectation(description: "Expect SFSafariViewController() to be presented")
        presentingViewControllerMock.onPresent = { viewController, animated, completion in
            XCTAssertNotNil(viewController as? SFSafariViewController)
            XCTAssertEqual(animated, true)
            completion?()
            safariVCExpectation.fulfill()
        }
        
        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }
        
        let appLauncherExpectation = expectation(description: "Expect appLauncher.openUniversalAppUrl() to be called")
        appLauncher.onOpenUniversalAppUrl = { url, completion in
            XCTAssertEqual(url, URL(string: "http://maps.apple.com")!)
            completion?(false)
            appLauncherExpectation.fulfill()
        }
        
        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }
        
        let action = RedirectAction(url: URL(string: "http://maps.apple.com")!, paymentData: "test_data")
        sut.handle(action)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testOpenHttpWebLink() {
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.universalRedirectComponent.appLauncher = appLauncher

        appLauncher.onOpenCustomSchemeUrl = { url, completion in
            XCTFail("appLauncher.openCustomSchemeUrl() must not to be called")
        }

        appLauncher.onOpenUniversalAppUrl = { url, completion in
            completion?(false)
        }

        delegate.onDidOpenExternalApplication = { _ in
            XCTFail("delegate.didOpenExternalApplication() must not to be called")
        }

        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")
        sut.handle(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? SFSafariViewController)

            sut.dismiss(true) {
                let topPresentedViewController = UIViewController.findTopPresenter()
                XCTAssertNil(topPresentedViewController as? SFSafariViewController)

                waitExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
