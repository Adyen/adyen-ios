//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents an error.
/// :nodoc:
public final class FormErrorItem: FormItem, Hidable {

    /// Indicates the error message.
    @AdyenObservable(nil) public var message: String?

    /// The error icon name.
    public let iconName: String

    /// The error item style.
    public let style: FormErrorItemStyle

    /// :nodoc:
    public var identifier: String?

    /// :nodoc:
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(true)

    /// :nodoc:
    public var subitems: [FormItem] = []

    /// Initializes the separator item.
    ///
    /// - Parameter message: The message.
    /// - Parameter iconName: The icon name.
    /// - Parameter style: a `FormErrorItemStyle` UI style.
    public init(message: String? = nil, iconName: String, style: FormErrorItemStyle = FormErrorItemStyle()) {
        self.iconName = iconName
        self.style = style
        self.message = message
    }

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
