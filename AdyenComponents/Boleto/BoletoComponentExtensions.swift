//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension BoletoComponent {
    
    /// Boleto component configuration.
    public struct Configuration {
        /// Pre-filled optional personal information about the shopper
        internal let shopperInfo: PrefilledShopperInformation
        
        /// A Boleto payment method
        internal let boletoPaymentMethod: BoletoPaymentMethod
        
        /// The payment to be made
        internal let payment: Payment?
        
        /// Indicates whether to show `sendCopyByEmail` checkbox and email text field
        internal let showEmailAddress: Bool
        
        /// Initializes the configuration struct with shopper information
        /// - Parameters:
        ///   - boletoPaymentMethod: A Boleto payment method
        ///   - payment: The payment to be made
        ///   - shopperInfo: Pre-filled optional personal information about the shopper
        public init(
            boletoPaymentMethod: BoletoPaymentMethod,
            payment: Payment?,
            shopperInfo: PrefilledShopperInformation?,
            showEmailAddress: Bool
        ) {
            self.boletoPaymentMethod = boletoPaymentMethod
            self.payment = payment
            self.shopperInfo = shopperInfo ?? PrefilledShopperInformation()
            self.showEmailAddress = showEmailAddress
        }
    }
    
}
