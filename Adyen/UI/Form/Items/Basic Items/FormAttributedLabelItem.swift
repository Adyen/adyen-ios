//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item that represent a single attributed UILabel element.
@_spi(AdyenInternal)
public class FormAttributedLabelItem: FormItem {

    public var subitems: [FormItem] = []

    public init(originalText: String,
                link: String,
                style: TextStyle,
                linkTextStyle: TextStyle,
                identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.linkTextStyle = linkTextStyle
        self.originalText = originalText
        self.link = link
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The style of the link text.
    public var linkTextStyle: TextStyle

    /// The text of the label.
    public var originalText: String

    // The link label.
    public var link: String

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = ADYLabel()
        label.numberOfLines = 0
        label.textAlignment = style.textAlignment
        label.textColor = style.color
        label.font = style.font
        label.backgroundColor = style.backgroundColor
        let attributedString = NSMutableAttributedString(string: originalText.replacingOccurrences(of: "#", with: " "))

        let linkRanges = linkRangesInString()

        let attributes = createAttributes(from: linkTextStyle)
        for linkRange in linkRanges {
            attributedString.addAttributes(attributes, range: linkRange)
        }

        label.attributedText = attributedString
        label.accessibilityIdentifier = identifier

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        return label
    }

    @objc private func labelTapped(gesture: UITapGestureRecognizer) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func linkRangesInString() -> [NSRange] {
        let pattern = "#(.+?)#"
        var ranges: [NSRange] = []
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: originalText, options: [], range: NSRange(location: 0, length: originalText.utf16.count))

            matches.forEach { match in
                let range = match.range(at: 0)
                ranges.append(range)
            }
        } catch {
            adyenPrint(error)
        }
        return ranges
    }

    private func createAttributes(from style: TextStyle) -> [NSAttributedString.Key: Any] {
        [.foregroundColor: style.color,
         .font: style.font,
         .backgroundColor: style.backgroundColor]
    }

}
