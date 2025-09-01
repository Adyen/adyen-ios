//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Simple form item that represent a single UILabel element.
@_spi(AdyenInternal)
public class FormLabelItem: FormItem {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []

    public init(text: String, style: TextStyle, identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.text = text
    }

    public init(
        text: String,
        identifier: String? = nil,
        labelStyle: AdyenLabelStyle = AdyenLabelStyle(),
        style: TextStyle = .init(font: .preferredFont(forTextStyle: .body), color: .red)
    ) {
        self.identifier = identifier
        self.text = text
        self.labelStyle = labelStyle
        self.style = style
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The text of the label.
    public var text: String

    /// The labelStyle from the adyen theme
    public var labelStyle: AdyenLabelStyle = .init()

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
