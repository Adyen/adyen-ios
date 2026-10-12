//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenUI
import Testing
import UIKit

@MainActor
struct AdyenLabelTests {

    private let style = CheckoutTheme.default.elements.labels.body

    @Test func textAssignedAfterStyleKeepsLineHeight() throws {
        let label = AdyenLabel()
        label.apply(style)
        label.text = "Body"

        let lineStyle = try #require(paragraphStyle(of: label))
        #expect(lineStyle.minimumLineHeight == 22)
        #expect(lineStyle.maximumLineHeight == 22)
        #expect(label.text == "Body")
    }

    @Test func textAssignedBeforeStyleGetsLineHeight() throws {
        let label = AdyenLabel()
        label.text = "Body"
        label.apply(style)

        #expect(try #require(paragraphStyle(of: label)).minimumLineHeight == 22)
    }

    @Test func colorOverriddenAfterStyleSurvivesTextChanges() {
        let label = AdyenLabel()
        label.apply(style)
        label.textColor = .systemPink
        label.text = "Body"

        #expect(label.textColor == .systemPink)
        #expect(label.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor == .systemPink)
    }

    @Test func attributedTextKeepsItsAttributesAndGetsLineHeight() throws {
        let label = AdyenLabel()
        label.apply(style)
        let emphasized = CheckoutTheme.default.elements.labels.bodyEmphasized.font
        label.attributedText = NSAttributedString(string: "Bold", attributes: [.font: emphasized])

        #expect(label.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == emphasized)
        #expect(try #require(paragraphStyle(of: label)).minimumLineHeight == 22)
    }

    @Test func heightIsAMultipleOfTheLineHeight() {
        let label = AdyenLabel()
        label.numberOfLines = 0
        label.apply(style)

        label.text = "One line"
        #expect(label.sizeThatFits(CGSize(width: 1000, height: .max)).height.rounded() == 22)

        label.text = "One line\nTwo lines"
        #expect(label.sizeThatFits(CGSize(width: 1000, height: .max)).height.rounded() == 44)
    }

    @Test func singleLineKeepsTailTruncation() throws {
        let label = AdyenLabel()
        label.apply(style)
        label.text = "Body"

        #expect(try #require(paragraphStyle(of: label)).lineBreakMode == .byTruncatingTail)
    }

    @Test func styleWithoutLineHeightBehavesLikeAPlainLabel() {
        let label = AdyenLabel()
        label.apply(AdyenLabelStyle(font: style.font, color: style.color))
        label.text = "Body"

        #expect(paragraphStyle(of: label) == nil)
    }

    @Test func textIsVerticallyCenteredInTheLine() throws {
        let label = AdyenLabel()
        label.apply(AdyenLabelStyle(font: style.font, color: .black, lineHeight: 44))
        label.text = "H"
        label.frame.size = label.sizeThatFits(CGSize(width: 100, height: .max))

        let reference = UILabel()
        reference.font = style.font
        reference.textColor = .black
        reference.text = "H"
        reference.frame.size = reference.sizeThatFits(CGSize(width: 100, height: .max))

        let offset = try #require(inkCenter(of: label)) - label.bounds.height / 2
        let referenceOffset = try #require(inkCenter(of: reference)) - reference.bounds.height / 2
        #expect(abs(offset - referenceOffset) <= 1, "offset \(offset), reference \(referenceOffset), height \(label.bounds.height), font line height \(style.font.lineHeight)")
    }

    // MARK: - Helpers

    private func paragraphStyle(of label: UILabel) -> NSParagraphStyle? {
        guard let attributedText = label.attributedText, attributedText.length > 0 else { return nil }
        let paragraphStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        return paragraphStyle?.minimumLineHeight == 0 ? nil : paragraphStyle
    }

    /// The vertical center of the rendered glyphs, in points.
    private func inkCenter(of view: UIView) -> CGFloat? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { context in
            view.layer.render(in: context.cgContext)
        }
        guard let cgImage = image.cgImage, let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
            return nil
        }
        let inkRows = (0..<cgImage.height).filter { row in
            (0..<cgImage.width).contains { column in
                let pixel = row * cgImage.bytesPerRow + column * cgImage.bitsPerPixel / 8
                return (0..<cgImage.bitsPerPixel / 8).contains { bytes[pixel + $0] > 0 }
            }
        }
        guard let first = inkRows.first, let last = inkRows.last else { return nil }
        return CGFloat(first + last + 1) / 2
    }
}
