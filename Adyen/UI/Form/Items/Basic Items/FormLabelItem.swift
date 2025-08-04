//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation
import UIKit

/// Simple form item that represent a single UILabel element.
@_spi(AdyenInternal)
public class FormLabelItem: FormItem {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []

    public init(text: String, style: TextStyle? = nil, identifier: String? = nil, labelStyle: LabelStyle = LabelStyle()) {
        self.identifier = identifier
        self.style = style
        self.labelStyle = labelStyle
        self.text = text
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle?

    /// The text of the label.
    public var text: String

    /// The labelStyle from the adyen theme
    public var labelStyle: LabelStyle = .init()

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = ADYLabel()
        label.text = text
        label.numberOfLines = 0
        label.accessibilityIdentifier = identifier
        label.font = labelStyle.font
        label.textColor = labelStyle.color
        label.textAlignment = labelStyle.textAlignment
        return label
    }
}

internal class ADYLabel: UILabel, AnyFormItemView {

    public var childItemViews: [AnyFormItemView] { [] }
    
    public func reset() { /* Do nothing */ }
    
}
