//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

extension AddressLookupSearchEmptyView {
    
    internal struct Style: ViewStyle {
        
        internal var title: TextStyle
        internal var subtitle: TextStyle
        internal var backgroundColor: UIColor
        
        internal init(
            title: TextStyle = .init(
                font: .preferredFont(forTextStyle: .headline),
                color: .Adyen.componentLabel
            ),
            subtitle: TextStyle = .init(
                font: .preferredFont(forTextStyle: .subheadline),
                color: .Adyen.componentSecondaryLabel
            ),
            backgroundColor: UIColor = .clear
        ) {
            self.title = title
            self.subtitle = subtitle
            self.backgroundColor = backgroundColor
        }
    }
}

internal class AddressLookupSearchEmptyView: UIStackView, SearchViewControllerEmptyView {
    
    /// The action to dismiss the search
    private let dismissSearchLink = "dismissSearch://"
    
    private let style: Style
    
    private let localizationParameters: LocalizationParameters?
    
    public var searchTerm: String {
        didSet { updateLabels() }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UITextView = {
        let textView = UITextView()
        textView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "textView")
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    private let dismissHandler: () -> Void
    
    // MARK: - Stack View
    
    internal init(
        searchTerm: String = "",
        style: Style = .init(),
        localizationParameters: LocalizationParameters? = nil,
        dismissHandler: @escaping () -> Void
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.searchTerm = searchTerm
        self.dismissHandler = dismissHandler
        
        super.init(frame: .zero)
        
        addArrangedSubview(titleLabel)
        setCustomSpacing(4.0, after: titleLabel)
        
        addArrangedSubview(subtitleLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .center
        distribution = .fill
        
        updateLabels()
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddressLookupSearchEmptyView {
    
    func updateLabels() {
        // TODO: Localization
        
        if searchTerm.isEmpty {
            titleLabel.text = "Enter your address"
        } else {
            titleLabel.text = "No results found"
        }
        
        titleLabel.textColor = style.title.color
        subtitleLabel.textColor = style.subtitle.color
        
        titleLabel.font = style.title.font
        subtitleLabel.font = style.subtitle.font
        
        configureSubtitleLabel(for: searchTerm)
    }
    
    private func configureSubtitleLabel(for searchTerm: String) {
        // TODO: Localization
        
        let string = searchTerm.isEmpty ?
            "or use %#manual address entry%#" :
            "'\(searchTerm)' did not match with anything, try again or use %#manual address entry%#"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributedString = NSMutableAttributedString(
            string: string,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: style.subtitle.font,
                .foregroundColor: style.subtitle.color
            ]
        )
        if let range = string.adyen.linkRanges().first {
            attributedString.addAttribute(.link, value: dismissSearchLink, range: range)
        }
        attributedString.mutableString.replaceOccurrences(of: "%#", with: "", range: NSRange(location: 0, length: attributedString.length))
        
        subtitleLabel.attributedText = attributedString
        subtitleLabel.delegate = self
    }
}

extension AddressLookupSearchEmptyView: UITextViewDelegate {
    
    internal func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.absoluteString == dismissSearchLink { dismissHandler() }
        return false
    }
}
