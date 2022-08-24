//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

extension PixView {
    
    internal class Model {
        
        internal let action: QRCodeAction
    
        internal let instruction: String
        
        internal let logoUrl: URL
        
        internal let observedProgress: Progress?
        
        internal let expiration: AdyenObservable<String?>
        
        internal let style: Style
        
        internal struct Style {
            
            internal let copyButton: ButtonStyle
            
            internal let instructionLabel: TextStyle
            
            internal let progressView: ProgressViewStyle
            
            internal let expirationLabel: TextStyle
            
            internal let logoCornerRounding: CornerRounding
            
            internal let backgroundColor: UIColor
        }
        
        internal init(action: QRCodeAction,
                      instruction: String,
                      logoUrl: URL,
                      observedProgress: Progress?,
                      expiration: AdyenObservable<String?>,
                      style: PixView.Model.Style) {
            self.action = action
            self.instruction = instruction
            self.logoUrl = logoUrl
            self.observedProgress = observedProgress
            self.expiration = expiration
            self.style = style
        }
    
    }
}
