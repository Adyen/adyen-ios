//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class CheckoutButton: UIButton {
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        layer.cornerRadius = Appearance.shared.checkoutButtonAttributes.cornerRadius
        updateBackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIButton
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        if let title = title {
            let attributes = Appearance.shared.checkoutButtonAttributes.titleAttributes
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            setAttributedTitle(attributedTitle, for: state)
            
            dynamicTypeController.observeDynamicType(for: self, withTextAttributes: attributes, textStyle: .body)
        } else {
            super.setTitle(title, for: state)
        }
    }
    
    // MARK: - UIControl
    
    internal override var isHighlighted: Bool {
        didSet {
            updateBackground()
        }
    }
    
    internal override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
            updateBackground()
        }
    }
    
    // MARK: - UIView
    
    internal override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: preferredHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: super.sizeThatFits(size).width, height: preferredHeight)
    }
    
    internal override var frame: CGRect {
        didSet {
            highlightedLayer.frame = bounds
        }
    }
    
    internal override func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateBackgroundColor()
    }
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    private let disabledTintColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 0.25)
    private let preferredHeight: CGFloat = 50
    
    private lazy var preferredTintColor = Appearance.shared.tintColor ?? tintColor
    
    private lazy var highlightedLayer: CALayer = {
        let highlightedLayer = CALayer()
        highlightedLayer.frame = self.bounds
        highlightedLayer.backgroundColor = UIColor.black.cgColor
        highlightedLayer.opacity = 0.0
        highlightedLayer.zPosition = 100
        layer.addSublayer(highlightedLayer)
        return highlightedLayer
    }()
    
    private func updateBackgroundColor() {
        guard isEnabled else {
            preferredTintColor = tintColor
            backgroundColor = disabledTintColor
            return
        }
        
        if let buttonBackgroundColor = Appearance.shared.checkoutButtonAttributes.backgroundColor {
            backgroundColor = buttonBackgroundColor
        } else {
            backgroundColor = preferredTintColor
        }
    }
    
    private func updateBackground() {
        switch (isEnabled, isHighlighted) {
        case (false, _):
            alpha = 0.5
            highlightedLayer.opacity = 0.0
        case (true, false):
            alpha = 1.0
            highlightedLayer.opacity = 0.0
        case (true, true):
            alpha = 1.0
            highlightedLayer.opacity = 0.4
        }
    }
}
