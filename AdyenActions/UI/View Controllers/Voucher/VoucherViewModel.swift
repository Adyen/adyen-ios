//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension VoucherView {
    
    internal struct Model {
        
        internal let amount: String
        
        internal let currency: String
        
        internal let logoUrl: URL
        
        internal let primaryButtonTitle: String
        
        internal let secondaryButtonTitle: String
        
        internal let style: Style
        
        internal struct Style {
            
            internal let actionButton: ButtonStyle
            
            internal let closeButton: ButtonStyle
            
            internal let amountLabel: TextStyle
            
            internal let currencyLabel: TextStyle
            
            internal let logoCornerRounding: CornerRounding
            
            internal let backgroundColor: UIColor
            
        }
        
    }
    
}
