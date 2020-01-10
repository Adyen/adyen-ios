//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A view representing a form card number item.
internal final class FormCardNumberItemView: FormValueItemView<FormCardNumberItem> {
    
    /// Initializes the form card number item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormCardNumberItem) {
        super.init(item: item)
        
        addSubview(stackView)
        
        backgroundColor = item.style.backgroundColor
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override var childItemViews: [AnyFormItemView] {
        return [textItemView]
    }
    
    // MARK: - Text Item View
    
    private lazy var textItemView: FormTextItemView = {
        let textItemView = FormTextItemView(item: item)
        textItemView.showsSeparator = false
        textItemView.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "textItem") }
        
        return textItemView
    }()
    
    // MARK: - Card Type Logos View
    
    private lazy var cardTypeLogosView: UIStackView = {
        let arrangedSubviews: [CardTypeLogoView] = item.cardTypeLogos.map { logo in
            let imageView = CardTypeLogoView(cardTypeLogo: logo, style: item.style.icon)
            imageView.backgroundColor = item.style.backgroundColor
            return imageView
        }
        let cardTypeLogosView = UIStackView(arrangedSubviews: arrangedSubviews)
        cardTypeLogosView.axis = .horizontal
        cardTypeLogosView.spacing = 4.0
        cardTypeLogosView.preservesSuperviewLayoutMargins = true
        cardTypeLogosView.isLayoutMarginsRelativeArrangement = true
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        
        return cardTypeLogosView
    }()
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textItemView, cardTypeLogosView])
        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline
        stackView.distribution = .fill
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = item.style.backgroundColor
        
        return stackView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

// MARK: - FormCardNumberItemView.CardTypeLogoView

private extension FormCardNumberItemView {
    
    private class CardTypeLogoView: NetworkImageView, Observer {
        
        internal init(cardTypeLogo: FormCardNumberItem.CardTypeLogo, style: ImageStyle) {
            super.init(frame: .zero)
            
            imageURL = cardTypeLogo.url
            
            layer.masksToBounds = style.clipsToBounds
            layer.cornerRadius = style.cornerRadius
            layer.borderWidth = style.borderWidth
            layer.borderColor = style.borderColor?.cgColor
            backgroundColor = style.backgroundColor
            
            setContentHuggingPriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .vertical)
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .vertical)
            
            bind(cardTypeLogo.isHidden, to: self, at: \.isHidden)
        }
        
        internal required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        internal override var intrinsicContentSize: CGSize {
            return CGSize(width: 24.0, height: 16.0)
        }
        
    }
    
}
