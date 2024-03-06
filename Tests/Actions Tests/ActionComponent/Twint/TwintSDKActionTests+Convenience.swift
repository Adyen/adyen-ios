//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable @_spi(AdyenInternal) import Adyen
@testable @_spi(AdyenInternal) import AdyenActions

extension TwintSDKActionTests {
    
    /// PresentationDelegateMock that fails when `doPresent` is called
    static func failingPresentationDelegateMock() -> PresentationDelegateMock {
        let presentationDelegateMock = PresentationDelegateMock()
        presentationDelegateMock.doPresent = { _ in
            XCTFail("Nothing should have been displayed")
        }
        return presentationDelegateMock
    }
    
    static func actionComponent(
        with twintSpy: TwintSpy,
        presentationDelegate: PresentationDelegate?
    ) -> TwintSDKActionComponent {
        
        let component = TwintSDKActionComponent(
            context: Dummy.context,
            configuration: .dummy,
            twint: twintSpy
        )
        
        component.presentationDelegate = presentationDelegate
        
        return component
    }
}
