//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum ExampleComponentFactory {
    
    internal static func dropIn(
        forSession isUsingSession: Bool,
        presenter: PresenterExampleProtocol
    ) -> ExampleComponentProtocol {
        
        if isUsingSession {
            return DropInExample(presenter: presenter)
        } else {
            return DropInAdvancedFlowExample(presenter: presenter)
        }
    }
    
    internal static func cardComponent(
        forSession isUsingSession: Bool,
        presenter: PresenterExampleProtocol
    ) -> ExampleComponentProtocol {
        
        if isUsingSession {
            return CardComponentExample(presenter: presenter)
        } else {
            return CardComponentAdvancedFlowExample(presenter: presenter)
        }
    }
    
    internal static func issuerListComponent(
        forSession isUsingSession: Bool,
        presenter: PresenterExampleProtocol
    ) -> ExampleComponentProtocol {
        
        if isUsingSession {
            return IssuerListComponentExample(presenter: presenter)
        } else {
            return IssuerListComponentAdvancedFlowExample(presenter: presenter)
        }
    }
    
    internal static func instantPaymentComponent(
        forSession isUsingSession: Bool,
        presenter: PresenterExampleProtocol
    ) -> ExampleComponentProtocol {
        
        if isUsingSession {
            return InstantPaymentComponentExample(presenter: presenter)
        } else {
            return InstantPaymentComponentAdvancedFlowExample(presenter: presenter)
        }
    }
    
    internal static func applePayComponent(
        forSession isUsingSession: Bool,
        presenter: PresenterExampleProtocol
    ) -> ExampleComponentProtocol {
        
        if isUsingSession {
            return ApplePayComponentExample(presenter: presenter)
        } else {
            return ApplePayComponentAdvancedFlowExample(presenter: presenter)
        }
    }
}
