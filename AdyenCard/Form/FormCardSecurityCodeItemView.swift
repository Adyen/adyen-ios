//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A view representing a form card security code item.
internal final class FormCardSecurityCodeItemView: FormTextItemView<FormCardSecurityCodeItem> {
    
    internal required init(item: FormCardSecurityCodeItem) {
        super.init(item: item)
        accessory = .customView(cardHintView)
        textField.allowsEditingActions = false
        
        observe(item.$selectedCard) { [weak self] cardsType in
            let number = cardsType == CardType.americanExpress ? "4" : "3"
            let localizedPlaceholder = localizedString(.cardCvcItemPlaceholderDigits, item.localizationParameters, number)

            if let textField = self?.textField {
                textField.apply(placeholderText: localizedPlaceholder, with: item.style.placeholderText)
            }
        }

        observe(item.$displayMode) { [weak self] _ in
            self?.updateValidationStatus()
        }
        
        item.$selectedCard.publish(nil)
    }
    
    internal lazy var cardHintView: HintView = {
        let view = HintView(item: self.item)
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cvvHintIcon")
        return view
    }()

    override internal func updateValidationStatus(forced: Bool = false) {
        super.updateValidationStatus(forced: forced)

        alpha = item.displayMode.isVisible ? 1.0 : 0.0
        isUserInteractionEnabled = item.displayMode.isVisible
        
        switch item.displayMode {
        case .optional:
            accessory = .customView(cardHintView)
        case .hidden, .required:
            break
        }
    }
    
    override internal func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        accessory = .customView(cardHintView)
        cardHintView.isHighlighted = true
    }
    
    override internal func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        cardHintView.isHighlighted = false
    }
    
}

extension FormCardSecurityCodeItemView {
    
    internal class HintView: UIImageView, Observer {
        
        private lazy var bundle = Bundle.cardInternalResources
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
            setupConstraints()
            observe(item.$selectedCard) { [weak self] cardType in self?.flipCard(toFront: cardType == CardType.americanExpress) }
        }
        
        @available(*, unavailable)
        internal required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// Indicate when user focused on security code field
        override internal var isHighlighted: Bool {
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
        
        override public var accessibilityIdentifier: String? {
            didSet {
                hintImage.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "imageView")
            }
        }
        
        private func setupConstraints() {
            addSubview(hintImage)
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            hintImage.adyen.anchor(inside: self)
        }
        
        private lazy var hintImage = UIImageView(image: UIImage(named: self.hintResource,
                                                                in: self.bundle,
                                                                compatibleWith: nil))
    }
}
