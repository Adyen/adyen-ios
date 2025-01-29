//
// Copyright (c) 2025 Adyen N.V.
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
            try super.tearDownWithError()
        }

        func testNoAppFound() throws {

            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let noAppFoundAlertExpectation = expectation(description: "No app found alert was shown")

            let expectedAlertMessage = "No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app."

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, .max)
                fetchBlockExpectation.fulfill()
                configurationsBlock([])
            } handlePay: { code, appConfiguration, callbackAppScheme, completionHandler in
                XCTFail("Pay should not have been called")
                completionHandler(nil)
            } handleRegisterForUOF: { _, _, _, completionHandler in
                XCTFail("RegisterForUOF should not have been called.")
                completionHandler(nil)
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
                sdkData: .init(token: "token", isStored: false),
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

            let expectedMaxIssuerNumber = 5
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let payBlockExpectation = expectation(description: "Pay was called")

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, expectedMaxIssuerNumber)
                fetchBlockExpectation.fulfill()
                configurationsBlock([.dummy])
            } handlePay: { code, appConfiguration, callbackAppScheme, completionHandler in
                payBlockExpectation.fulfill()
                XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
                XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
                XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
                completionHandler(nil)
            } handleRegisterForUOF: { _, _, _, completionHandler in
                XCTFail("RegisterForUOF should not have been called.")
                completionHandler(nil)
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
                configuration: .dummy(maxIssuerNumber: expectedMaxIssuerNumber),
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

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, .max)
                fetchBlockExpectation.fulfill()
                configurationsBlock(expectedAppConfigurations)
            } handlePay: { code, appConfiguration, callbackAppScheme, completionHandler in
                payBlockExpectation.fulfill()
                XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
                XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
                XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
                completionHandler(nil)
            } handleRegisterForUOF: { _, _, _, completionHandler in
                XCTFail("RegisterForUOF should not have been called.")
                completionHandler(nil)
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

        func testPayError() throws {

            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let payBlockExpectation = expectation(description: "Pay was called")
            let alertExpectation = expectation(description: "Alert was shown")

            let expectedAlertMessage = "Error Message"

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, .max)
                fetchBlockExpectation.fulfill()
                configurationsBlock([.dummy])
            } handlePay: { code, appConfiguration, callbackAppScheme, completionHandler in
                payBlockExpectation.fulfill()
                let error = MockError(errorDescription: expectedAlertMessage)
                completionHandler(error)
            } handleRegisterForUOF: { _, _, _, completionHandler in
                XCTFail("RegisterForUOF should not have been called.")
                completionHandler(nil)
            } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
                XCTFail("Twint controller should not have been shown")
                return nil
            } handleOpenUrl: { url, responseHandler in
                XCTFail("Handle open should not have been called")
                return false
            }

            let analyticsProviderMock = AnalyticsProviderMock()
            let presentationDelegate = PresentationDelegateMock()
            
            presentationDelegate.doPresent = { component in
                let alertController = try XCTUnwrap(component.viewController as? UIAlertController)
                XCTAssertEqual(alertController.message, expectedAlertMessage)
                let errorEvent = analyticsProviderMock.errors[0]
                XCTAssertEqual(errorEvent.component, "paymentMethodType")
                XCTAssertEqual(errorEvent.errorType, .thirdParty)
                XCTAssertEqual(
                    errorEvent.code,
                    AnalyticsConstants.ErrorCode.thirdPartyError.stringValue
                )
                alertExpectation.fulfill()
            }

            let twintActionComponent = Self.actionComponent(
                with: twintSpy,
                context: Dummy.context(with: analyticsProviderMock),
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

        func testHandleWhenIsStoredEnabledAndSingleAppFoundShouldCallTwintRegisterForUOF() throws {
            // Given
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let registerForUFO = expectation(description: "registerForUFO was called")

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, .max)
                fetchBlockExpectation.fulfill()
                configurationsBlock([.dummy])
            } handlePay: { _, _, _, completionHandler in
                XCTFail("Pay should not have been called.")
                completionHandler(nil)
            } handleRegisterForUOF: { code, appConfiguration, callbackAppScheme, completionHandler in
                registerForUFO.fulfill()
                XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
                XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
                XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
                completionHandler(nil)
            } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
                XCTFail("Twint controller should not have been shown")
                return nil
            } handleOpenUrl: { url, responseHandler in
                XCTFail("Handle open should not have been called")
                return false
            }

            let presentationDelegate = Self.failingPresentationDelegateMock()
            let sut = Self.actionComponent(
                with: twintSpy,
                presentationDelegate: presentationDelegate,
                delegate: nil
            )

            // When
            let sdkData = TwintSDKData(token: "token", isStored: true)
            let action = TwintSDKAction(
                sdkData: sdkData,
                paymentData: "payment-data",
                paymentMethodType: "payment-method",
                type: "type"
            )
            sut.handle(action)

            // Then
            wait(
                for: [fetchBlockExpectation, registerForUFO],
                timeout: 1,
                enforceOrder: true
            )
        }

        func testHandleWhenIsStoredEnabledAndMultipleAppsFoundShouldCallTwintRegisterForUOF() throws {
            // Given
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let registerForUFO = expectation(description: "registerForUFO was called")
            let pickerExpectation = expectation(description: "App picker was shown")
            let expectedAppConfigurations: [TWAppConfiguration] = [.dummy, .dummy]
            let expectedAppPicker = UIAlertController(title: "Picker", message: nil, preferredStyle: .actionSheet)

            var appSelectionHandler: ((TWAppConfiguration?) -> Void)? = nil
            var appCancelHandler: (() -> Void)? = nil

            let twintSpy = TwintSpy { maxIssuerNumber, configurationsBlock in
                XCTAssertEqual(maxIssuerNumber, .max)
                fetchBlockExpectation.fulfill()
                configurationsBlock(expectedAppConfigurations)
            } handlePay: { _, _, _, completionHandler in
                XCTFail("Pay should not have been called.")
                completionHandler(nil)
            } handleRegisterForUOF: { code, appConfiguration, callbackAppScheme, completionHandler in
                registerForUFO.fulfill()
                XCTAssertEqual(code, TwintSDKAction.dummy.sdkData.token)
                XCTAssertEqual(appConfiguration.appDisplayName, TWAppConfiguration.dummy.appDisplayName)
                XCTAssertEqual(appConfiguration.appURLScheme, TWAppConfiguration.dummy.appURLScheme)
                XCTAssertEqual(callbackAppScheme, TwintSDKActionComponent.Configuration.dummy.callbackAppScheme)
                completionHandler(nil)
            } handleController: { installedAppConfigurations, selectionHandler, cancelHandler in
                XCTAssertEqual(installedAppConfigurations, expectedAppConfigurations)
                appSelectionHandler = selectionHandler
                appCancelHandler = cancelHandler
                return expectedAppPicker
            } handleOpenUrl: { url, responseHandler in
                XCTFail("Handle open should not have been called")
                return false
            }

            let sut = TwintSDKActionComponent(
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

            sut.presentationDelegate = presentationDelegateMock

            // When
            let sdkData = TwintSDKData(token: "token", isStored: true)
            let action = TwintSDKAction(
                sdkData: sdkData,
                paymentData: "payment-data",
                paymentMethodType: "payment-method",
                type: "type"
            )
            sut.handle(action)

            // Then
            wait(
                for: [fetchBlockExpectation, pickerExpectation],
                timeout: 1,
                enforceOrder: true
            )

            // When app was selected

            let selectionHandler = try XCTUnwrap(appSelectionHandler)
            selectionHandler(.dummy)

            wait(for: [registerForUFO], timeout: 1)

            // When selection was cancelled

            let cancelExpectation = expectation(description: "Component was cancelled")

            let actonComponentDelegateMock = ActionComponentDelegateMock()
            actonComponentDelegateMock.onDidFail = { error, component in
                XCTAssertEqual(error as! ComponentError, ComponentError.cancelled)
                XCTAssertTrue(component === sut)
                cancelExpectation.fulfill()
            }
            sut.delegate = actonComponentDelegateMock

            let cancelHandler = try XCTUnwrap(appCancelHandler)
            cancelHandler()

            wait(for: [cancelExpectation], timeout: 1)
        }
    }

#endif
