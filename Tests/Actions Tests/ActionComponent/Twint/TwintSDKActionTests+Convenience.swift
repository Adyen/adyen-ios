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

extension TWAppConfiguration {
    static var dummy: TWAppConfiguration {
        let twintAppConfiguration = TWAppConfiguration()
        twintAppConfiguration.appDisplayName = "Test App"
        twintAppConfiguration.appURLScheme = "scheme://"
        return twintAppConfiguration
    }
}

extension TwintSDKActionComponent.Configuration {
    static var dummy: Self {
        .init(callbackAppScheme: "ui-host")
    }
}

extension TwintSDKAction {
    static var dummy: TwintSDKAction {
        .init(
            sdkData: .init(token: "token"),
            paymentData: "paymentData",
            paymentMethodType: "paymentMethodType",
            type: "type"
        )
    }
}

extension TwintSDKActionTests {
    
    static func actionComponent(
        with twintSpy: TwintSpy,
        presentationDelegate: PresentationDelegate?,
        delegate: ActionComponentDelegate?
    ) -> TwintSDKActionComponent {
        
        let component = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        component.presentationDelegate = presentationDelegate
        component.delegate = delegate
        
        return component
    }
    
    // MARK: PresentationDelegateMock
    
    /// PresentationDelegateMock that fails when `doPresent` is called
    static func failingPresentationDelegateMock() -> PresentationDelegateMock {
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { _ in
            XCTFail("Nothing should have been displayed")
        }
        return presentationDelegateMock
    }
    
    /// ActionComponentDelegateMock that fails when `onDidFail` is called
    static func successFlowActionComponentDelegateMock(
        onProvide: @escaping (ActionComponentData) -> Void
    ) -> ActionComponentDelegateMock {
        
        let actonComponentDelegateMock = ActionComponentDelegateMock()
        actonComponentDelegateMock.onDidFail = { error, component in
            XCTFail("delegate.onDidFail should not have been called")
        }
        actonComponentDelegateMock.onDidProvide = { data, component in
            onProvide(data)
        }
        
        return actonComponentDelegateMock
    }
    
    /// ActionComponentDelegateMock that fails when `onDidFail` is called
    static func failureFlowActionComponentDelegateMock(
        onDidFail: @escaping (Error) -> Void
    ) -> ActionComponentDelegateMock {
        
        let actonComponentDelegateMock = ActionComponentDelegateMock()
        actonComponentDelegateMock.onDidFail = { error, component in
            onDidFail(error)
        }
        actonComponentDelegateMock.onDidProvide = { data, component in
            XCTFail("delegate.onDidProvide should not have been called")
        }
        
        return actonComponentDelegateMock
    }
}

#endif
