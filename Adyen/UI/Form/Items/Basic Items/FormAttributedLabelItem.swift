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
    private let style: TextStyle

    /// The style of the link text.
    private let linkTextStyle: TextStyle

    /// The text of the label.
    private let originalText: String

    // The links present in the label.
    private let links: [String]

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = LinkTextViewFormItem { [weak self] linkIndex in
            self?.handleLinkTapped(atIndex: linkIndex)
        }
        
        label.update(
            text: originalText,
            style: style,
            linkRangeDelimiter: "#"
        )
        
        label.accessibilityIdentifier = identifier

        return label
    }
    
    private func handleLinkTapped(atIndex linkIndex: Int) {
        guard linkIndex < links.count, let url = URL(string: links[linkIndex]) else {
            AdyenAssertion.assertionFailure(message: "Link index \(linkIndex) out of bounds \(links.count)")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

private class LinkTextViewFormItem: LinkTextView, AnyFormItemView {
    
    public var childItemViews: [AnyFormItemView] { [] }
    
    public func reset() {}
}
