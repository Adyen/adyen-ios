//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class CheckoutButton: UIButton {
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        contentEdgeInsets = appearanceConfiguration.internalCheckoutButtonTitleEdgeInsets ?? .zero
        
        tintColor = appearanceConfiguration.tintColor
        
        let cornerRadius = appearanceConfiguration.internalCheckoutButtonCornerRadius
        clipsToBounds = cornerRadius > 0.0
        layer.cornerRadius = cornerRadius
        
        updateBackgroundColor()
    }
    
    // MARK: - Title
    
    internal override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            setAttributedTitle(nil, for: state)
            
            return
        }
        
        let attributedTitle = NSAttributedString(string: title,
                                                 attributes: appearanceConfiguration.internalCheckoutButtonTitleTextAttributes)
        setAttributedTitle(attributedTitle, for: state)
    }
    
    // MARK: - Background Color
    
    private func updateBackgroundColor() {
        switch (isEnabled, isHighlighted) {
        case (false, _):
            backgroundColor = tintColor.withAlphaComponent(0.5)
        case (true, false):
            backgroundColor = tintColor
        case (true, true):
            backgroundColor = tintColor.withAlphaComponent(0.75)
        }
    }
    
    internal override func tintColorDidChange() {
        super.tintColorDidChange()
        
        updateBackgroundColor()
    }
    
    internal override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    internal override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    // MARK: Appearance Configuration
    
    private var appearanceConfiguration: AppearanceConfiguration {
        return AppearanceConfiguration.shared
    }
    
}
