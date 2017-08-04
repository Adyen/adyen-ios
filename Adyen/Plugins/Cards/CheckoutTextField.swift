//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutTextField: UITextField {
    var valid = false
}

class CardNumberField: CheckoutTextField {
    
    var cardTypeDetected: ((CardType?) -> Void)?
    
    var card: CardType? {
        didSet {
            self.cardTypeDetected?(card)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class CardExpirationField: CheckoutTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboardType = .numberPad
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class CardCvcField: CheckoutTextField {}

class CardInstallmentField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
