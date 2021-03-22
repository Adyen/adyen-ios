//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
import SafariServices
import XCTest

class RedirectComponentTests: XCTestCase {

    func testUIConfiguration() {
        let action = RedirectAction(url: URL(string: "https://adyen.com")!, paymentData: "data")
        let style = RedirectComponentStyle(preferredBarTintColor: UIColor.red,
                                           preferredControlTintColor: UIColor.black,
                                           modalPresentationStyle: .fullScreen)
        let sut = BrowserComponent(url: action.url, style: style)
        XCTAssertNotNil(sut.viewController as? SFSafariViewController)
        XCTAssertEqual(sut.viewController.modalPresentationStyle, .fullScreen)
        XCTAssertEqual((sut.viewController as! SFSafariViewController).preferredBarTintColor, UIColor.red)
        XCTAssertEqual((sut.viewController as! SFSafariViewController).preferredControlTintColor, UIColor.black)
    }
    
    func testOpenCustomSchemeSuccess() {
        let sut = RedirectComponent()
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
        let sut = RedirectComponent()
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
        let sut = RedirectComponent()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate
        let appLauncher = AppLauncherMock()
        sut.appLauncher = appLauncher
        
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
        sut.appLauncher = appLauncher
        let presentingViewControllerMock = PresentingViewControllerMock()
        sut.presentationDelegate = presentingViewControllerMock
        let topViewController: UIViewController! = UIViewController.findTopPresenter()
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
        sut.presentationDelegate = UIViewController.findTopPresenter()
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

        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")
        sut.handle(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter()
            XCTAssertNotNil(topPresentedViewController as? SFSafariViewController)

            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testOpenHttpWebLinkAndClose() {
        let sut = RedirectComponent()
        sut.presentationDelegate = UIViewController.findTopPresenter()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")
        sut.handle(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")

        delegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            waitExpectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter() as? SFSafariViewController
            XCTAssertNotNil(topPresentedViewController)

            topPresentedViewController!.delegate?.safariViewControllerDidFinish?(topPresentedViewController!)
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    @available(iOS 13.0, *)
    func testOpenHttpWebLinkAndDragedDown() {
        let sut = RedirectComponent()
        sut.presentationDelegate = UIViewController.findTopPresenter()
        let delegate = ActionComponentDelegateMock()
        sut.delegate = delegate

        let action = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "test_data")
        sut.handle(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")

        delegate.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            waitExpectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let topPresentedViewController = UIViewController.findTopPresenter() as? SFSafariViewController
            XCTAssertNotNil(topPresentedViewController)

            topPresentedViewController!.presentationController?.delegate?.presentationControllerDidDismiss?(topPresentedViewController!.presentationController!)
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
}

extension UIViewController {
    public static func findTopPresenter() -> UIViewController? {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            AdyenAssertion.assert(message: "Application's keyWindow is not set or have no rootViewController")
            return nil
        }
        return viewController.adyen.topPresenter
    }

}
