//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item that represent a single UILabel element.
/// :nodoc:
public class FormLabelItem: FormItem {

    /// :nodoc:
    public var subitems: [FormItem] = []

    /// :nodoc:
    public init(text: String, style: TextStyle, identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.text = text
    }

    /// :nodoc:
    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The text of the label.
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
        label.adyen.round(using: style.cornerRounding)
        return label
    }
}

private class ADYLabel: UILabel, AnyFormItemView {

    public var childItemViews: [AnyFormItemView] { [] }
    
    /// :nodoc:
    public func reset() { /* Do nothing */ }
    
}
