//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) @testable import Adyen

class CancellableMock: AdyenCancellable {
    
    private let onCancelHandler: () -> Void
    
    init(onCancelHandler: @escaping () -> Void) {
        self.onCancelHandler = onCancelHandler
    }
    
    func cancel() {
        onCancelHandler()
    }
}
