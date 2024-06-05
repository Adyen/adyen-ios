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

    extension TwintSDKActionTests {
    
        func test_twintInteraction_succeeded() throws {
        
            let expectedError = TWErrorCode.B_SUCCESS
            let handleOnDidProvideExpectation = expectation(description: "delegate.onDidProvide was called")
        
            let delegate = Self.successFlowActionComponentDelegateMock {
                XCTAssertTrue($0.details is AwaitActionDetails)
                XCTAssertEqual($0.paymentData, TwintSDKAction.dummy.paymentData)
                handleOnDidProvideExpectation.fulfill()
            }
        
            try singleAppFlow(
                delegate: delegate,
                expectedTwintError: expectedError
            )
        
            wait(
                for: [handleOnDidProvideExpectation],
                timeout: 1,
                enforceOrder: true
            )
        }
    
        func test_twintInteraction_failed() throws {
        
            let expectedError = TWErrorCode.B_ERROR
            let handleOnDidProvideExpectation = expectation(description: "delegate.onDidProvide was called")
        
            let delegate = Self.failureFlowActionComponentDelegateMock {
                let errorCode = ($0 as NSError).code
                XCTAssertEqual(errorCode, expectedError.rawValue)
                handleOnDidProvideExpectation.fulfill()
            }
        
            try singleAppFlow(
                delegate: delegate,
                expectedTwintError: expectedError
            )
        
            wait(
                for: [handleOnDidProvideExpectation],
                timeout: 1,
                enforceOrder: true
            )
        }
    
        func test_twintInteractionSucceeded_pollingFailed() throws {
        
            let expectedError = TWErrorCode.B_SUCCESS
            let handleOnDidProvideExpectation = expectation(description: "delegate.onDidProvide was called")
        
            let delegate = Self.failureFlowActionComponentDelegateMock {
                XCTAssertTrue($0 is TwintSDKActionTests.PollingError)
                handleOnDidProvideExpectation.fulfill()
            }
        
            try singleAppFlow(
                delegate: delegate,
                expectedTwintError: expectedError,
                shouldFailPolling: true
            )
        
            wait(
                for: [handleOnDidProvideExpectation],
                timeout: 1,
                enforceOrder: true
            )
        }
    }

    // MARK: - Flow

    private extension TwintSDKActionTests {
    
        func singleAppFlow(
            delegate: ActionComponentDelegate,
            expectedTwintError: TWErrorCode,
            shouldFailPolling: Bool = false
        ) throws {
        
            let fetchBlockExpectation = expectation(description: "Fetch was called")
            let payBlockExpectation = expectation(description: "Pay was called")
            let handleOpenBlockExpectation = expectation(description: "Handle open was called")
            let expectedRedirectUrl = URL(string: "ui-host://payment")!
        
            var twintResponseHandler: ((Error?) -> Void)?
        
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
        
            let presentationDelegate = Self.failingPresentationDelegateMock()

            let twintActionComponent = Self.actionComponent(
                with: twintSpy,
                presentationDelegate: presentationDelegate,
                delegate: delegate,
                shouldFailPolling: shouldFailPolling
            )

            // When
        
            twintActionComponent.handle(.dummy)
        
            // Then
        
            wait(
                for: [fetchBlockExpectation, payBlockExpectation],
                timeout: 1,
                enforceOrder: true
            )
        
            try XCTAssertTrue(RedirectListener.applicationDidOpen(from: expectedRedirectUrl))
        
            wait(
                for: [handleOpenBlockExpectation],
                timeout: 1
            )
        
            let responseHandler = try XCTUnwrap(twintResponseHandler)
            responseHandler(NSError(domain: "", code: expectedTwintError.rawValue))
        }
    }

#endif
