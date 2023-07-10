//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Simple form item that represent a single attributed UILabel element.
@_spi(AdyenInternal)
public class FormAttributedLabelItem: FormItem {

    public var subitems: [FormItem] = []

    public init(originalText: String,
                links: [String],
                style: TextStyle,
                linkTextStyle: TextStyle,
                identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.linkTextStyle = linkTextStyle
        self.originalText = originalText
        self.links = links
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The style of the link text.
    public var linkTextStyle: TextStyle

    /// The text of the label.
    public var originalText: String

    // The links present in the label.
    public var links: [String]

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = LinkTextViewFormItem { [weak self] linkIndex in
            guard let self else { return }
            guard linkIndex < links.count, let url = URL(string: links[linkIndex]) else {
                AdyenAssertion.assertionFailure(message: "Insufficient amount of links provided")
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        label.update(
            text: originalText,
            style: style,
            linkRangeDelimiter: "#"
        )
        
        label.accessibilityIdentifier = identifier

        return label
    }
}

private class LinkTextViewFormItem: LinkTextView, AnyFormItemView {
    
    public var childItemViews: [AnyFormItemView] { [] }
    
    public func reset() {}
}
