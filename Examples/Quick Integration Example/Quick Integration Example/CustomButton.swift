//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CustomButton: UIButton {
    private let color = #colorLiteral(red: 0.4107530117, green: 0.8106812239, blue: 0.7224243283, alpha: 1)
    private let colorDisabled = #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1)
    private let colorHighlighted = #colorLiteral(red: 0.4672650099, green: 0.923529923, blue: 0.823000133, alpha: 1)
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? color : colorDisabled
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? colorHighlighted : color
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title?.uppercased(), for: state)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 50)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height / 2
    }
    
}
