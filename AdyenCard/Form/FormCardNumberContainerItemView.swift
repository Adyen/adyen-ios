//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal final class FormCardNumberContainerItemView: FormVerticalStackItemView<FormCardNumberContainerItem> {
    
    override internal var canBecomeFirstResponder: Bool {
        views.first { $0.canBecomeFirstResponder } != nil
    }

    override internal func becomeFirstResponder() -> Bool {
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder() ?? super.becomeFirstResponder()
    }
    
}
