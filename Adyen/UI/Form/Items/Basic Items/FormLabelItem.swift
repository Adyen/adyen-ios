//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item that represent a single UILable element.
/// :nodoc:
public class FormLabelItem: FormItem {

    /// :nodoc:
    public init(text: String, style: TextStyle, identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.text = text
    }

    /// :nodoc:
    public var identifier: String?

    /// The style of the lable.
    public var style: TextStyle

    /// The text of the lable.
    public var text: String

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = ADYLabel()
        label.text = text
        label.numberOfLines = 0
        label.accessibilityIdentifier = identifier
        label.font = style.font
        label.textColor = style.color
        label.textAlignment = style.textAlignment
        label.backgroundColor = style.backgroundColor
        return label
    }
}

private class ADYLabel: UILabel {}

/// :nodoc:
extension ADYLabel: AnyFormItemView {

    public var childItemViews: [AnyFormItemView] { [] }

    public var delegate: FormItemViewDelegate? {
        get {
            objc_getAssociatedObject(self, &UIViewAssociatedKeys.delegate) as? FormItemViewDelegate
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIViewAssociatedKeys.delegate,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

private enum UIViewAssociatedKeys {
    internal static var delegate = "delegate"
}
