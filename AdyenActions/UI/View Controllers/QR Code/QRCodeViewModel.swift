//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension QRCodeView {

    internal class Model {

        internal enum ActionButton {
            case copyCode
            case saveAsImage
        }

        internal let action: QRCodeAction
        
        internal var actionButtonType: ActionButton {
            switch action.paymentMethodType {
            case .promptPay, .duitNow, .payNow, .upiQRCode:
                return .saveAsImage
            case .pix:
                return .copyCode
            }
        }

        internal let instruction: String
        
        internal var payment: Payment?
        
        internal let logoUrl: URL
        
        internal let observedProgress: Progress?
        
        internal let expiration: AdyenObservable<String?>
        
        internal let style: Style
        
        internal struct Style {
            
            internal let copyCodeButton: ButtonStyle

            internal let saveAsImageButton: ButtonStyle
            
            internal let instructionLabel: TextStyle
            
            internal let amountToPayLabel: TextStyle
            
            internal let progressView: ProgressViewStyle
            
            internal let expirationLabel: TextStyle
            
            internal let logoCornerRounding: CornerRounding
            
            internal let backgroundColor: UIColor
        }
        
        internal init(action: QRCodeAction,
                      instruction: String,
                      payment: Payment?,
                      logoUrl: URL,
                      observedProgress: Progress?,
                      expiration: AdyenObservable<String?>,
                      style: QRCodeView.Model.Style) {
            self.action = action
            self.instruction = instruction
            self.payment = payment
            self.logoUrl = logoUrl
            self.observedProgress = observedProgress
            self.expiration = expiration
            self.style = style
        }
        
    }
}
