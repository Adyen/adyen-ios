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
    
        struct PollingError: Error {}
    
        static func actionComponent(
            with twintSpy: TwintSpy,
            presentationDelegate: PresentationDelegate?,
            delegate: ActionComponentDelegate?,
            shouldFailPolling: Bool = false
        ) -> TwintSDKActionComponent {
        
            let pollingHandler = PollingHandlerMock()
            let pollingBuilder = AwaitActionHandlerProviderMock { _ in
                pollingHandler
            } onQRHandler: { _ in
                XCTFail("onQRHandler should not have been called")
                return PollingHandlerMock()
            }
        
            let component = TwintSDKActionComponent(
                context: Dummy.context,
                configuration: .dummy,
                twint: twintSpy,
                pollingComponentBuilder: pollingBuilder
            )
        
            pollingHandler.onHandle = { action in
                let additionalDetails = AwaitActionDetails(payload: "payload")
                let actionData = ActionComponentData(details: additionalDetails, paymentData: action.paymentData)
            
                if shouldFailPolling {
                    pollingHandler.delegate?.didFail(with: PollingError(), from: component)
                } else {
                    pollingHandler.delegate?.didProvide(actionData, from: component)
                }
            }
        
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
        
            let actionComponentDelegateMock = ActionComponentDelegateMock()
            actionComponentDelegateMock.onDidFail = { error, component in
                XCTFail("delegate.onDidFail should not have been called")
            }
            actionComponentDelegateMock.onDidProvide = { data, component in
                onProvide(data)
            }
        
            return actionComponentDelegateMock
        }
    
        /// ActionComponentDelegateMock that fails when `onDidFail` is called
        static func failureFlowActionComponentDelegateMock(
            didFailClosure: @escaping (Error) -> Void
        ) -> ActionComponentDelegateMock {
        
            let actonComponentDelegateMock = ActionComponentDelegateMock()
            actonComponentDelegateMock.onDidFail = { error, component in
                didFailClosure(error)
            }
            actonComponentDelegateMock.onDidProvide = { data, component in
                XCTFail("delegate.onDidProvide should not have been called")
            }
        
            return actonComponentDelegateMock
        }
    }

#endif
