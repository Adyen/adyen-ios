//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal final class FormCardNumberContainerItemView: FormVerticalStackItemView<FormCardNumberContainerItem> {
    
    /// :nodoc:
    override public var canBecomeFirstResponder: Bool {
        views.first { $0.canBecomeFirstResponder } != nil
    }

    /// :nodoc:
    override public func becomeFirstResponder() -> Bool {
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder() ?? super.becomeFirstResponder()
    }
    
}
