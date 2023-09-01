//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

extension QRCodeView {

    class Model {

        enum ActionButton {
            case copyCode
            case saveAsImage
        }

        let action: QRCodeAction
        
        var actionButtonType: ActionButton {
            switch action.paymentMethodType {
            case .promptPay, .duitNow, .payNow, .upiQRCode:
                return .saveAsImage
            case .pix:
                return .copyCode
            }
        }

        let instruction: String
        
        var payment: Payment?
        
        let logoUrl: URL
        
        let observedProgress: Progress?
        
        let expiration: AdyenObservable<String?>
        
        let style: Style
        
        struct Style {
            
            let copyCodeButton: ButtonStyle

            let saveAsImageButton: ButtonStyle
            
            let instructionLabel: TextStyle
            
            let amountToPayLabel: TextStyle
            
            let progressView: ProgressViewStyle
            
            let expirationLabel: TextStyle
            
            let logoCornerRounding: CornerRounding
            
            let backgroundColor: UIColor
        }
        
        init(action: QRCodeAction,
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
