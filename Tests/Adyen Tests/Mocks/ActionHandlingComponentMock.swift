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

final class ActionHandlingComponentMock: ActionHandlingComponent {

    var context: AdyenContext {
        Dummy.context
    }
    
    var onAction: ((Action) -> Void)?
    
    func handle(_ action: Action) {
        onAction?(action)
    }
}
