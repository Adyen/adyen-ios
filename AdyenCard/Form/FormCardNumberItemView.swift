//
// Copyright (c) 2019 Adyen B.V.
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
        
        return textItemView
    }()
    
    // MARK: - Card Type Logos View
    
    private lazy var cardTypeLogosView: UIStackView = {
        let arrangedSubviews = item.cardTypeLogos.map(CardTypeLogoView.init)
        let cardTypeLogosView = UIStackView(arrangedSubviews: arrangedSubviews)
        cardTypeLogosView.axis = .horizontal
        cardTypeLogosView.spacing = 4.0
        cardTypeLogosView.preservesSuperviewLayoutMargins = true
        cardTypeLogosView.isLayoutMarginsRelativeArrangement = true
        
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
        
        internal init(cardTypeLogo: FormCardNumberItem.CardTypeLogo) {
            super.init(frame: .zero)
            
            imageURL = cardTypeLogo.url
            
            layer.masksToBounds = true
            layer.cornerRadius = 3.0
            layer.borderWidth = 1.0 / UIScreen.main.nativeScale
            layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
            
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
