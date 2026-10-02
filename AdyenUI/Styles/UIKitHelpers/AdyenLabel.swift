//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A label that renders an `AdyenLabelStyle`, including its line height.
///
/// `UILabel` has no line-height property, so the line height is applied through `attributedText`.
/// It is re-applied whenever `text` or `attributedText` is assigned, so it survives text that is set after styling.
/// The current `font`, `textColor` and `textAlignment` are used, so call sites can still override them after `apply(_:)`.
package class AdyenLabel: UILabel {

    /// The style to render. Setting it updates `font`, `textColor` and `textAlignment`.
    package var style: AdyenLabelStyle? {
        didSet {
            guard let style else { return }
            font = style.font
            textColor = style.color
            textAlignment = style.textAlignment
            applyLineHeight()
        }
    }

    override package var text: String? {
        get { super.text }
        set {
            super.text = newValue
            applyLineHeight()
        }
    }

    override package var attributedText: NSAttributedString? {
        get { super.attributedText }
        set { super.attributedText = newValue.map(applyingLineHeight(to:)) }
    }

    override package var font: UIFont? {
        didSet { applyLineHeight() }
    }

    override package var textColor: UIColor? {
        didSet { applyLineHeight() }
    }

    override package var textAlignment: NSTextAlignment {
        didSet { applyLineHeight() }
    }

    // MARK: - Private

    private func applyLineHeight() {
        guard style?.lineHeight != nil, let text = super.text else { return }
        super.attributedText = applyingLineHeight(
            to: NSAttributedString(string: text, attributes: [.font: font as Any, .foregroundColor: textColor as Any])
        )
    }

    private func applyingLineHeight(to attributedText: NSAttributedString) -> NSAttributedString {
        guard let lineHeight = style?.lineHeight, attributedText.length > 0 else { return attributedText }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode

        let result = NSMutableAttributedString(attributedString: attributedText)
        let range = NSRange(location: 0, length: result.length)
        result.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        result.addAttribute(.baselineOffset, value: (lineHeight - (font?.lineHeight ?? 0)) / 2, range: range)
        return result
    }
}
