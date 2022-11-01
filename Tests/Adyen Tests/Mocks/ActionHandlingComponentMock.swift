//
//  ActionHandlingComponentMock.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions

internal final class ActionHandlingComponentMock: ActionHandlingComponent {

    internal var context: AdyenContext {
        Dummy.context
    }
    
    internal var onAction: ((Action) -> Void)?
    
    internal func handle(_ action: Action) {
        onAction?(action)
    }
}
