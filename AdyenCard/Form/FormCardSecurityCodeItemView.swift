//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A view representing a form card security code item.
internal final class FormCardSecurityCodeItemView: FormTextItemView<FormCardSecurityCodeItem>, Observer {
    
    private static let fourDigitHint = "1234"
    private static let threeDigitHint = "123"
    
    internal required init(item: FormCardSecurityCodeItem) {
        super.init(item: item)
        accessory = .customView(cardHintView)
        textField.placeholder = FormCardSecurityCodeItemView.threeDigitHint
        observe(item.selectedCard, eventHandler: { [weak self] card in
            // TODO: replace with actual translated values
            // let localizationKey = "creditCard.cvcField.placeholder.\(isAmex ? "4" : "3")digits"
            // textField.placeholder = ADYLocalizedString(localizationKey, localizationParameters)
            let hintText = card == CardType.americanExpress ?
                FormCardSecurityCodeItemView.fourDigitHint :
                FormCardSecurityCodeItemView.threeDigitHint
            self?.textField.placeholder = hintText
        })
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var cardHintView: HintView = {
        let view = HintView(item: self.item)
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cvvHintIcon")
        return view
    }()
    
    internal override func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        accessory = .customView(cardHintView)
        cardHintView.isHighlighted = true
    }
    
    internal override func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        cardHintView.isHighlighted = false
    }
    
}

extension FormCardSecurityCodeItemView {
    
    internal class HintView: UIImageView, Observer {
        
        private lazy var bundle = Bundle(for: type(of: self))
        private let minimumAlpha: CGFloat = 0.3
        private let blinkDuration = 1.0
        
        internal var showFront: Bool = false
        
        private var logoResource: String {
            showFront ? "ic_card_front" : "ic_card_back"
        }
        
        private var hintResource: String {
            showFront ? "ic_card_front_cvv_focus" : "ic_card_back_cvv_focus"
        }
        
        internal init(item: FormCardSecurityCodeItem) {
            super.init(frame: .zero)
            image = UIImage(named: logoResource, in: self.bundle, compatibleWith: nil)
            translatesAutoresizingMaskIntoConstraints = false
            setupConstrints()
            observe(item.selectedCard) { [weak self] cardType in self?.flipCard(toFront: cardType == CardType.americanExpress) }
        }
        
        internal required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// Indicate when user focused on security code field
        internal override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    animateHint()
                } else {
                    hintImage.alpha = 1
                    hintImage.layer.removeAllAnimations()
                }
            }
        }
        
        private func flipCard(toFront: Bool) {
            guard showFront != toFront else { return }
            showFront = toFront
            UIView.transition(with: self,
                              duration: 0.5,
                              options: .transitionFlipFromRight,
                              animations: {
                                  self.image = UIImage(named: self.logoResource, in: self.bundle, compatibleWith: nil)
                                  self.hintImage.image = UIImage(named: self.hintResource, in: self.bundle, compatibleWith: nil)
                              },
                              completion: nil)
        }
        
        private func animateHint() {
            UIView.animate(withDuration: blinkDuration,
                           delay: 0,
                           options: [.repeat, .autoreverse],
                           animations: { self.hintImage.alpha = self.minimumAlpha },
                           completion: nil)
        }
        
        private func setupConstrints() {
            addSubview(hintImage)
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            NSLayoutConstraint.activate([
                hintImage.topAnchor.constraint(equalTo: topAnchor),
                hintImage.bottomAnchor.constraint(equalTo: bottomAnchor),
                hintImage.leftAnchor.constraint(equalTo: leftAnchor),
                hintImage.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        private lazy var hintImage: UIImageView = {
            let view = UIImageView(image: UIImage(named: self.hintResource, in: self.bundle, compatibleWith: nil))
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    }
}
