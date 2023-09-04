//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension QRCodeView {
    
    class Model {
    
        let instruction: String
        
        let logoUrl: URL
        
        let observedProgress: Progress?
        
        let expiration: Observable<String?>
        
        let style: Style
        
        struct Style {
            
            let copyButton: ButtonStyle
            
            let instructionLabel: TextStyle
            
            let progressView: ProgressViewStyle
            
            let expirationLabel: TextStyle
            
            let logoCornerRounding: CornerRounding
            
            let backgroundColor: UIColor
        }
        
        init(instruction: String,
             logoUrl: URL,
             observedProgress: Progress?,
             expiration: Observable<String?>,
             style: QRCodeView.Model.Style) {
            self.instruction = instruction
            self.logoUrl = logoUrl
            self.observedProgress = observedProgress
            self.expiration = expiration
            self.style = style
        }
    
    }
}
