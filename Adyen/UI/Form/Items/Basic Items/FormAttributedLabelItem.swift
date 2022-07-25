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

    public init(termsAndConditionsText: String,
                link: String,
                style: TextStyle,
                linkTextStyle: TextStyle,
                identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.linkTextStyle = linkTextStyle
        self.termsAndConditionsText = termsAndConditionsText
        self.link = link
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The style of the link text.
    public var linkTextStyle: TextStyle

    /// The text of the label.
    public var termsAndConditionsText: String

    // The link label.
    public var link: String

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let label = ADYLabel()
        label.numberOfLines = 0
        label.textAlignment = style.textAlignment
        label.textColor = style.color
        label.font = style.font
        label.backgroundColor = style.backgroundColor
        let attributedString = NSMutableAttributedString(string: termsAndConditionsText.replacingOccurrences(of: "#", with: " "))

        let linkRanges = getLinkRangesInString()

        let attributes = createAttributes(from: linkTextStyle)
        for linkRange in linkRanges {
            attributedString.addAttributes(attributes, range: linkRange)
        }

        label.attributedText = attributedString
        label.accessibilityIdentifier = identifier
        label.adyen.round(using: style.cornerRounding)

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

    private func getTermsandConditionsSubstringRange(mainString: String) -> NSRange {
        let termsAndConditionsText = mainString.split(separator: "#")[1]
        if let range = mainString.range(of: termsAndConditionsText) {
            return NSRange(range, in: mainString)
        }
        return NSRange(location: 0, length: 0)
    }

    private func getLinkRangesInString() -> [NSRange] {
        let pattern = "#(.+?)#"
        var ranges: [NSRange] = []
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // swiftlint:disable:next line_length
            let matches = regex.matches(in: termsAndConditionsText, options: [], range: NSRange(location: 0, length: termsAndConditionsText.utf16.count))

            matches.forEach({ match in
                let range = match.range(at: 0)
                ranges.append(range)
            })
        } catch let error {
            adyenPrint(error)
        }
        return ranges
    }

    private func createAttributes(from style: TextStyle) -> [NSAttributedString.Key: Any] {
        return [.foregroundColor: style.color,
                .font: style.font,
                .backgroundColor: style.backgroundColor]
    }

}
