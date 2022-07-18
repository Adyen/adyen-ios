//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Simple form item that represent a single attributed UILabel element.
@_spi(AdyenInternal)
public class FormAttributedLabelItem: FormItem {

    public var subitems: [FormItem] = []

    public init(tAndCText: String, link: String, style: TextStyle, identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.tAndCText = tAndCText
        self.link = link
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The text of the label.
    public var tAndCText: String

    // The link label.
    public var link: String

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = ADYLabel()
        label.numberOfLines = 0
        label.textAlignment = style.textAlignment
        label.textColor = style.color

        let attributedString = NSMutableAttributedString(string: tAndCText.replacingOccurrences(of: "#", with: " "))
        let rangeOfTAndCText = getTandCSubstringStartIndexes(mainString: tAndCText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.Adyen.defaultBlue, range: rangeOfTAndCText)

        label.attributedText = attributedString
        label.accessibilityIdentifier = identifier
        label.font = style.font
        label.backgroundColor = style.backgroundColor
        label.adyen.round(using: style.cornerRounding)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        return label
    }

    @objc private func labelTapped(gesture: UITapGestureRecognizer) {
        if let url = URL(string: link) {
            AppLauncher().openCustomSchemeUrl(url, completion: nil)
        }
    }

    private func getTandCSubstringStartIndexes(mainString: String) -> NSRange {
        let tAndCLinkText = mainString.split(separator: "#")[1]
        print(tAndCLinkText)
        if let range = mainString.range(of: tAndCLinkText) {
            return NSRange(range, in: mainString)
        }
        return NSRange(location: 0, length: 0)
    }

}
