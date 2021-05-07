//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

/// :nodoc
internal protocol PreApplePayViewDelegate: AnyObject {
    
    func pay()
    
}

/// :nodoc:
internal final class PreApplePayView: UIView, Localizable {
    
    /// :nodoc:
    private let model: Model
    
    /// The delegate of the view
    internal weak var delegate: PreApplePayViewDelegate?
    
    /// :nodoc:
    internal var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        
        buildUI()
        backgroundColor = model.style.backgroundColor
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    private func buildUI() {
        addButton()
        addHintLabel()
    }
    
    /// :nodoc:
    private func addButton() {
        addSubview(payButton)
        payButton.translatesAutoresizingMaskIntoConstraints = false

        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            leadingAnchor = safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = safeAreaLayoutGuide.trailingAnchor
        } else {
            leadingAnchor = self.leadingAnchor
            trailingAnchor = self.trailingAnchor
        }
        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: topAnchor, constant: 13.0),
            payButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            payButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            payButton.heightAnchor.constraint(equalToConstant: 48.0)
        ])
        payButton.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "applePayButton")
    }
    
    /// :nodoc:
    private func addHintLabel() {
        addSubview(hintLabel)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let bottomAnchore: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            bottomAnchore = safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchore = self.bottomAnchor
        }
        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 15.0),
            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchore, constant: -24.0)
        ])
        hintLabel.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "hintLabel")
    }
    
    /// :nodoc:
    private lazy var payButton: PKPaymentButton = {
        let style: PKPaymentButtonStyle
        if #available(iOS 14.0, *) {
            style = .automatic
        } else if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            style = .white
        } else {
            style = .black
        }
        
        let payButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: style)
        
        payButton.addTarget(self, action: #selector(onPayButtonTap), for: .primaryActionTriggered)
        
        return payButton
    }()
    
    /// :nodoc:
    private lazy var hintLabel: UILabel = {
        let hintLabel = UILabel()
        hintLabel.font = model.style.hintLabel.font
        hintLabel.textColor = model.style.hintLabel.color
        hintLabel.textAlignment = model.style.hintLabel.textAlignment
        hintLabel.text = model.hint
        return hintLabel
    }()
    
    /// :nodoc
    @objc private func onPayButtonTap() {
        delegate?.pay()
    }
}

extension PreApplePayView {
    
    internal struct Model {
        
        internal let hint: String
        
        internal let style: Style
        
        internal struct Style {
            
            internal let hintLabel: TextStyle
            
            internal let backgroundColor: UIColor
            
        }
    }
}
