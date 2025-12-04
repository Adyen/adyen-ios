//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Foundation

class ActionWrapperSpy: ActionWrapperViewController {
    var callbackInvoked: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callbackInvoked?()
    }
}
