//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension VoucherView {
    
    internal struct Model {
        
        internal let identifier: String
        
        internal let amount: String
        
        internal let currency: String
        
        internal let logoUrl: URL
        
        internal let mainButton: String
        
        internal let secondaryButtonTitle: String
        
        internal let codeConfirmationTitle: String
        
        internal let mainButtonType: Button
        
        internal let style: Style
        
        internal struct Style {
            
            internal let editButton: ButtonStyle
            
            internal let doneButton: ButtonStyle
            
            internal let mainButton: ButtonStyle
            
            internal let secondaryButton: ButtonStyle
            
            internal let codeConfirmationColor: UIColor
            
            internal let amountLabel: TextStyle
            
            internal let currencyLabel: TextStyle
            
            internal let logoCornerRounding: CornerRounding
            
            internal let backgroundColor: UIColor
            
        }
        
        internal enum Button {
            case addToAppleWallet
            case save
        }
        
    }
    
}
