//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension QRCodeView {
    
    internal struct Model {
        
        internal let instruction: String
        
        internal let logoUrl: URL
        
        internal let style: Style
        
        internal struct Style {
            
            internal var copyButton: ButtonStyle
            
            internal var instructionLabel: TextStyle
            
            internal var backgroundColor: UIColor
        }
    
    }
}
