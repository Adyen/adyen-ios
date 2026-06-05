//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the issuer list component.
package struct IssuerListDetails: PaymentMethodDetails {
    
    package var checkoutAttemptId: String?

    /// The payment method type.
    package let type: PaymentMethodType

    /// The selected issuer.
    package let issuer: String

    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    package var sdkData: String?

    /// Initializes the Issuer List details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The issuer list payment method.
    ///   - issuer: The selected issuer.
    package init(paymentMethod: IssuerListPaymentMethod, issuer: String) {
        self.type = paymentMethod.type
        self.issuer = issuer
    }
    
}

/// Contains the details supplied by the MOLPay component.
package typealias MOLPayDetails = IssuerListDetails

/// Contains the details supplied by the Dotpay component.
package typealias DotpayDetails = IssuerListDetails

/// Contains the details supplied by the EPS component.
package typealias EPSDetails = IssuerListDetails

/// Contains the details supplied by the Entercash component.
package typealias EntercashDetails = IssuerListDetails

/// Contains the details supplied by the OpenBanking component.
package typealias OpenBankingDetails = IssuerListDetails

/// Contains the details supplied by the Online Banking Poland component.
package typealias OnlineBankingPolandDetails = IssuerListDetails
