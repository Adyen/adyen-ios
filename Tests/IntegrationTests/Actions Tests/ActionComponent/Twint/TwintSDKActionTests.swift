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

    final class TwintSDKActionTests: XCTestCase {
    
        override func tearDownWithError() throws {
            AdyenAssertion.listener = nil
        }
    
        func testNoAppFound() throws {
        
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let noAppFoundAlertExpectation = expectation(description: "No app found alert was shown")
        
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
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
                return nil
            } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
                XCTFail("Twint controller should not have been shown")
                return nil
            } handleOpenUrl: { url, responseHandler in
                XCTFail("Handle open should not have been called")
                return false
            }
        
            let presentationDelegate = Self.failingPresentationDelegateMock()

            let twintActionComponent = Self.actionComponent(
                with: twintSpy,
                presentationDelegate: presentationDelegate,
                delegate: nil
            )

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
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
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
                XCTAssertTrue(alertController === expectedAppPicker)
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
            actonComponentDelegateMock.onDidFailClosure = { error, component in
                XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
                XCTAssertTrue(component === twintActionComponent)
                cancelExpectation.fulfill()
            }
            twintActionComponent.delegate = actonComponentDelegateMock
        
            let cancelHandler = try XCTUnwrap(appCancelHandler)
            cancelHandler()
        
            wait(for: [cancelExpectation], timeout: 1)
        }
    
        func testPayError() throws {
        
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let payBlockExpectation = expectation(description: "Pay was called")
            let alertExpectation = expectation(description: "Alert was shown")
        
            let expectedAlertMessage = "Error Message"
        
            let twintSpy = TwintSpy { configurationsBlock in
                fetchBlockExpectation.fulfill()
                configurationsBlock([.dummy])
            } handlePay: { code, appConfiguration, callbackAppScheme in
                payBlockExpectation.fulfill()
                return MockError(errorDescription: expectedAlertMessage)
            } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
                XCTFail("Twint controller should not have been shown")
                return nil
            } handleOpenUrl: { url, responseHandler in
                XCTFail("Handle open should not have been called")
                return false
            }

            let presentationDelegate = PresentationDelegateMock()
            presentationDelegate.doPresent = { component in
                let alertController = try XCTUnwrap(component.viewController as? UIAlertController)
                XCTAssertEqual(alertController.message, expectedAlertMessage)
                alertExpectation.fulfill()
            }
        
            let twintActionComponent = Self.actionComponent(
                with: twintSpy,
                presentationDelegate: presentationDelegate,
                delegate: nil
            )

            // When
        
            twintActionComponent.handle(.dummy)
        
            // Then
        
            wait(
                for: [fetchBlockExpectation, payBlockExpectation, alertExpectation],
                timeout: 1,
                enforceOrder: true
            )
        }
    }

#endif
