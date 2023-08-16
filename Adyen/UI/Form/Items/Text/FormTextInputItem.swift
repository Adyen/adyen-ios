//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item for plain text input
/// :nodoc:
public final class FormTextInputItem: FormTextItem, Hidable {

    /// :nodoc:
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    /// :nodoc:
    @AdyenObservable(true) public var isEnabled: Bool
    
    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Initiate new instance of `FormTextInputItem`
    /// - Parameter style: The `FormTextItemStyle` UI style.
    override public init(style: FormTextItemStyle = FormTextItemStyle()) {
        super.init(style: style)
    }
    
    /// :nodoc:
    override public func isValid() -> Bool {
        isHidden.wrappedValue ? true : super.isValid()
    }
}
