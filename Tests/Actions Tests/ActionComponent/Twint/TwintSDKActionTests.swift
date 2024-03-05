//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable @_spi(AdyenInternal) import Adyen
@testable @_spi(AdyenInternal) import AdyenActions

#if canImport(TwintSDK)
import TwintSDK
#endif

#if canImport(TwintSDK)

private extension TWAppConfiguration {
    static var dummy: TWAppConfiguration {
        let twintAppConfiguration = TWAppConfiguration()
        twintAppConfiguration.appDisplayName = "Test App"
        twintAppConfiguration.appURLScheme = "scheme://"
        return twintAppConfiguration
    }
}

private extension TwintSDKActionComponent.Configuration {
    static var dummy: Self {
        .init(returnUrl: "ui-host://")
    }
}

private extension TwintSDKAction {
    static var dummy: TwintSDKAction {
        .init(
            sdkData: .init(token: "token"),
            paymentData: "paymentData",
            paymentMethodType: "paymentMethodType",
            type: "type"
        )
    }
}

final class TwintSDKActionTests: XCTestCase {

    func testNoAppFound() throws {
        
        let fetchBlockExpectation = expectation(description: "Fetch was called")
        let noAppFoundAlertExpectation = expectation(description: "No app found alert was shown")
        
        // TODO: Get the message from the localizations
        let expectedAlertMessage = "No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app."
        
        let twintSpy = TwintSpy { configurationsBlock in
            fetchBlockExpectation.fulfill()
            configurationsBlock([])
        } handlePay: { code, appConfiguration, callbackAppScheme in
            XCTFail("Pay should not have been called")
            return nil
        } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
            XCTFail("Twint controller should not have been shown")
            return nil
        } handleOpenUrl: { url, responseHandler in
            XCTFail("Handle open should not have been called")
            return false
        }

        let twintActionComponent = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { component in
            let alertController = try XCTUnwrap(component.viewController as? UIAlertController)
            XCTAssertEqual(alertController.message, expectedAlertMessage)
            noAppFoundAlertExpectation.fulfill()
        }
        
        twintActionComponent.presentationDelegate = presentationDelegateMock

        // When
        
        twintActionComponent.handle(.init(
            sdkData: .init(token: "token"), 
            paymentData: "paymentData",
            paymentMethodType: "paymentMethodType",
            type: "type"
        ))
        
        // Then
        
        wait(
            for: [fetchBlockExpectation, noAppFoundAlertExpectation],
            timeout: 1,
            enforceOrder: true
        )
    }
    
    func testSingleAppFound() throws {
        
        let fetchBlockExpectation = expectation(description: "Fetch was called")
        let payBlockExpectation = expectation(description: "Pay was called")
        
        let twintSpy = TwintSpy { configurationsBlock in
            fetchBlockExpectation.fulfill()
            configurationsBlock([.dummy])
        } handlePay: { code, appConfiguration, callbackAppScheme in
            payBlockExpectation.fulfill()
            XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
            XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
            XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
            XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.returnUrl)
            return nil
        } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
            XCTFail("Twint controller should not have been shown")
            return nil
        } handleOpenUrl: { url, responseHandler in
            XCTFail("Handle open should not have been called")
            return false
        }

        let twintActionComponent = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { component in
            XCTFail("Nothing should have been displayed")
        }
        
        twintActionComponent.presentationDelegate = presentationDelegateMock

        // When
        
        twintActionComponent.handle(.dummy)
        
        // Then
        
        wait(
            for: [fetchBlockExpectation, payBlockExpectation],
            timeout: 1,
            enforceOrder: true
        )
    }
    
    func testMultipleAppsFound() throws {
        
        let fetchBlockExpectation = expectation(description: "Fetch was called")
        let payBlockExpectation = expectation(description: "Pay was called")
        let pickerExpectation = expectation(description: "App picker was shown")
        let expectedAppConfigurations: [TWAppConfiguration] = [.dummy, .dummy]
        let expectedAppPicker = UIAlertController(title: "Picker", message: nil, preferredStyle: .actionSheet)
        
        var appSelectionHandler: ((TWAppConfiguration?) -> Void)? = nil
        var appCancelHandler: (() -> Void)? = nil
        
        let twintSpy = TwintSpy { configurationsBlock in
            fetchBlockExpectation.fulfill()
            configurationsBlock(expectedAppConfigurations)
        } handlePay: { code, appConfiguration, callbackAppScheme in
            payBlockExpectation.fulfill()
            XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
            XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
            XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
            XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.returnUrl)
            return nil
        } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
            XCTAssertEqual(installedAppConfigurations, expectedAppConfigurations)
            appSelectionHandler = selectionHandler
            appCancelHandler = cancelHandler
            return expectedAppPicker
        } handleOpenUrl: { url, responseHandler in
            XCTFail("Handle open should not have been called")
            return false
        }

        let twintActionComponent = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { component in
            let alertController = try XCTUnwrap(component.viewController as? UIAlertController)
            XCTAssertEqual(alertController, expectedAppPicker)
            pickerExpectation.fulfill()
        }
        
        twintActionComponent.presentationDelegate = presentationDelegateMock

        // When
        
        twintActionComponent.handle(.dummy)
        
        // Then
        
        wait(
            for: [fetchBlockExpectation, pickerExpectation],
            timeout: 1,
            enforceOrder: true
        )
        
        // When app was selected
        
        let selectionHandler = try XCTUnwrap(appSelectionHandler)
        selectionHandler(.dummy)
        
        wait(for: [payBlockExpectation], timeout: 1)
        
        // When selection was cancelled
        
        let cancelExpectation = expectation(description: "Component was cancelled")
        
        let actonComponentDelegateMock = ActionComponentDelegateMock()
        actonComponentDelegateMock.onDidFail = { error, component in
            XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
            XCTAssertTrue(component === twintActionComponent)
            cancelExpectation.fulfill()
        }
        twintActionComponent.delegate = actonComponentDelegateMock
        
        let cancelHandler = try XCTUnwrap(appCancelHandler)
        cancelHandler()
        
        wait(for: [cancelExpectation], timeout: 1)
    }
    
    func testSuccessFlow() throws {
        
        let fetchBlockExpectation = expectation(description: "Fetch was called")
        let payBlockExpectation = expectation(description: "Pay was called")
        let handleOpenBlockExpectation = expectation(description: "Handle open was called")
        let handleOnDidProvideExpectation = expectation(description: "delegate.onDidProvide was called")
        let expectedRedirectUrl = URL(string: "ui-host://payment")!
        
        var twintResponseHandler: ((Error?) -> Void)? = nil
        
        let twintSpy = TwintSpy { configurationsBlock in
            fetchBlockExpectation.fulfill()
            configurationsBlock([.dummy])
        } handlePay: { code, appConfiguration, callbackAppScheme in
            payBlockExpectation.fulfill()
            return nil
        } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
            XCTFail("Twint controller should not have been shown")
            return nil
        } handleOpenUrl: { url, responseHandler in
            XCTAssertEqual(url, expectedRedirectUrl)
            twintResponseHandler = responseHandler
            handleOpenBlockExpectation.fulfill()
            return true
        }

        let twintActionComponent = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { component in
            XCTFail("Nothing should have been displayed")
        }
        
        twintActionComponent.presentationDelegate = presentationDelegateMock

        // When
        
        twintActionComponent.handle(.dummy)
        
        // Then
        
        wait(
            for: [fetchBlockExpectation, payBlockExpectation],
            timeout: 1,
            enforceOrder: true
        )
        
        _ = try RedirectListener.applicationDidOpen(from: expectedRedirectUrl)
        
        wait(
            for: [handleOpenBlockExpectation],
            timeout: 1,
            enforceOrder: true
        )
        
        let actonComponentDelegateMock = ActionComponentDelegateMock()
        actonComponentDelegateMock.onDidFail = { error, component in
            XCTFail("delegate.onDidFail should not have been called")
        }
        actonComponentDelegateMock.onDidProvide = { data, component in
            XCTAssertTrue(data.details is TwintActionDetails)
            XCTAssertEqual(data.paymentData, TwintSDKAction.dummy.paymentData)
            handleOnDidProvideExpectation.fulfill()
        }
        
        twintActionComponent.delegate = actonComponentDelegateMock
        
        let responseHandler = try XCTUnwrap(twintResponseHandler)
        responseHandler(NSError(domain: "", code: TWErrorCode.B_SUCCESS.rawValue))
        
        wait(
            for: [handleOnDidProvideExpectation],
            timeout: 1,
            enforceOrder: true
        )
    }
    
    
    func testPayError() throws {
        // TODO: handlePay returns an error
    }
    
    func testFailureFlow() throws {
        // TODO: responseHandler returns an !B_SUCCESS error
    }
}

#endif
