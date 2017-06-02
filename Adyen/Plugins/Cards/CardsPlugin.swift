//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
import AdyenCSE

class CardsPlugin: BasePlugin {
    
    override func linnearFlow() -> Bool {
        guard let method = self.method else {
            return super.linnearFlow()
        }
        
        if method.oneClick {
            return false
        }
        
        return true
    }
}

extension CardsPlugin: UIPresentable {
    
    func detailsPresenter() -> PaymentMethodDetailsPresenter? {
        return CardsDetailsPresenter()
    }
}

extension CardsPlugin: RequiresFinalState {
    
    internal func finishWith(state: PaymentStatus, completion: (() -> Void)?) {
        completion?()
    }
}
