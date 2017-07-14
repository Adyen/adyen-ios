//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
import AdyenCSE

class CardsPlugin: BasePlugin {
    
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
