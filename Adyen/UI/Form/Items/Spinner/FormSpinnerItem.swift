//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A form item that represents an activity indicator (spinner)
@_spi(AdyenInternal)
public final class FormSpinnerItem: FormItem {
    public var subitems: [FormItem] = []
    
    public var identifier: String?
    
    @AdyenObservable(false) public var isAnimating: Bool
    
    public init(subitems: [FormItem] = [], identifier: String? = nil) {
        self.subitems = subitems
        self.identifier = identifier
    }
    
    @_spi(AdyenInternal)
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
