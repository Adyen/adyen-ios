//
//  ActionHandlingComponentMock.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
import Adyen
import AdyenActions

internal final class ActionHandlingComponentMock: ActionHandlingComponent {
    
    internal let apiContext: adyenContext.apiContext = Dummy.context

    internal var adyenContext: AdyenContext {
        return .init(apiContext: adyenContext.apiContext)
    }
    
    internal var onAction: ((Action) -> Void)?
    
    internal func handle(_ action: Action) {
        onAction?(action)
    }
}
