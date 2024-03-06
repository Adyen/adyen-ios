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
    
    /// ActionComponentDelegateMock that fails when `onDidFail` is called
    private static func actonComponentDelegateMock(
        onProvide: @escaping (ActionComponentData) -> Void
    ) -> ActionComponentDelegateMock {
        
        let actonComponentDelegateMock = ActionComponentDelegateMock()
        actonComponentDelegateMock.onDidFail = { error, component in
            XCTFail("delegate.onDidFail should not have been called")
        }
        actonComponentDelegateMock.onDidProvide = { data, component in
            XCTAssertTrue(data.details is TwintActionDetails)
            XCTAssertEqual(data.paymentData, TwintSDKAction.dummy.paymentData)
            onProvide(data)
        }
        
        return actonComponentDelegateMock
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

        let twintActionComponent = Self.actionComponent(
            with: twintSpy,
            presentationDelegate: Self.failingPresentationDelegateMock()
        )

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
            timeout: 1
        )
        
        let responseHandler = try XCTUnwrap(twintResponseHandler)
        responseHandler(NSError(domain: "", code: TWErrorCode.B_SUCCESS.rawValue))
        
        wait(
            for: [handleOnDidProvideExpectation],
            timeout: 1,
            enforceOrder: true
        )
    }
}

#endif
