//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension VoucherView {
    
    struct Model {
        
        let identifier: String
        
        let amount: String
        
        let currency: String
        
        let logoUrl: URL
        
        let mainButton: String
        
        let secondaryButtonTitle: String
        
        let codeConfirmationTitle: String
        
        let mainButtonType: Button
        
        let style: Style
        
        struct Style {
            
            let editButton: ButtonStyle
            
            let doneButton: ButtonStyle
            
            let mainButton: ButtonStyle
            
            let secondaryButton: ButtonStyle
            
            let codeConfirmationColor: UIColor
            
            let amountLabel: TextStyle
            
            let currencyLabel: TextStyle
            
            let logoCornerRounding: CornerRounding
            
            let backgroundColor: UIColor
            
        }
        
        enum Button {
            case addToAppleWallet
            case save
        }
        
    }
    
}
