//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
