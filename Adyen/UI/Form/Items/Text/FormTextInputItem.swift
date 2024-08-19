//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item for plain text input
@_spi(AdyenInternal)
public final class FormTextInputItem: FormTextItem {

    @AdyenObservable(true) public var isEnabled: Bool
    
    internal var focusHandler: (() -> Void)?
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Initiate new instance of `FormTextInputItem`
    /// - Parameter style: The `FormTextItemStyle` UI style.
    override public init(style: FormTextItemStyle = FormTextItemStyle()) {
        super.init(style: style)
    }
    
    override public func isValid() -> Bool {
        isHidden.wrappedValue ? true : super.isValid()
    }
    
    public func focus() {
        AdyenAssertion.assert(message: "`focusHandler` needs to be set", condition: focusHandler == nil)
        focusHandler?()
    }
}
