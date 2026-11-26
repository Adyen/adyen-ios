//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// An item for plain text input
@_spi(AdyenInternal)
open class FormTextInputItem: FormTextItem {

    @AdyenObservable(true) public var isEnabled: Bool
    
    open var focusHandler: (() -> Void)?

    override open func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Initiate new instance of `FormTextInputItem`
    /// - Parameter style: The `FormTextItemStyle` UI style.
    @MainActor
    override public init(style: FormTextItemStyle) {
        super.init(style: style)
    }

    /// Initiate new instance of `FormTextInputItem` with the default style.
    @MainActor
    public convenience init() {
        self.init(style: FormTextItemStyle())
    }
    
    override public func isValid() -> Bool {
        isHidden.wrappedValue ? true : super.isValid()
    }
    
    open func focus() {
        AdyenAssertion.assert(message: "`focusHandler` needs to be set", condition: focusHandler == nil)
        focusHandler?()
    }
}
