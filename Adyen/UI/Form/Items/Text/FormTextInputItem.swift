//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item for plain text input
@_spi(AdyenInternal)
public final class FormTextInputItem: FormTextItem, Hidable {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    @AdyenObservable(true) public var isEnabled: Bool
    
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
}
