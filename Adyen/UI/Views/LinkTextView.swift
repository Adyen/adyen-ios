//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A text view that easily makes links - delimited with a `linkRangeDelimiter` - selectable
///
/// Use ``update(text:style:linkRangeDelimiter:)`` to update the content
package class LinkTextView: UITextView {
    
    private let linkSelectionHandler: (_ linkIndex: Int) -> Void
    
    /// Initializes a LinkTextView
    ///
    /// - Parameters:
    ///    - linkSelectionHandler: A closure that is called when a link is selected. Including the index of the link.
    public init(linkSelectionHandler: @escaping (_ linkIndex: Int) -> Void) {
        self.linkSelectionHandler = linkSelectionHandler
        
        super.init(frame: .zero, textContainer: nil)
        
        super.delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        isEditable = false
        isSelectable = true
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the attributedString with the provided text and adds selectable links
    ///
    /// - Parameters:
    ///   - text: The text including the delimited links e.g. "Some text %#this is a link%#".
    ///   - style: The style of the text
    ///   - linkRangeDelimiter: The delimiter indicating the link range. Defaults to `%#`.
    public func update(
        text: String,
        style: TextStyle,
        linkRangeDelimiter: String = "%#"
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = style.textAlignment
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: style.font,
            .foregroundColor: style.color
        ]
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: attributes
        )
        
        text.adyen.linkRanges.enumerated().forEach { index, range in
            attributedString.addAttribute(.link, value: "\(index)", range: range)
        }
        
        attributedString.mutableString.replaceOccurrences(
            of: linkRangeDelimiter,
            with: "",
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        self.attributedText = attributedString
        self.backgroundColor = style.backgroundColor
    }
}

// MARK: - UITextViewDelegate

extension LinkTextView: UITextViewDelegate {
    
    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        
        if let index = Int(URL.absoluteString) {
            linkSelectionHandler(index)
        }
        
        return false
    }
}
