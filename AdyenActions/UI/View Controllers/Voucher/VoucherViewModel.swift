//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

extension VoucherView {
    
    internal struct Model {
        
        internal let action: VoucherAction
        
        internal let identifier: String
        
        internal let amount: String
        
        internal let currency: String
        
        internal let logoUrl: URL
        
        internal let mainButton: String
        
        internal let secondaryButtonTitle: String
        
        internal let codeConfirmationTitle: String
        
        internal let mainButtonType: Button
        
        internal let theme: CheckoutTheme
        
        internal let imageLoader: ImageLoading
        
        internal enum Button {
            case addToAppleWallet
            case save
        }
        
    }
    
}
