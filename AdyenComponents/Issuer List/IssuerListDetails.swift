//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the issuer list component.
public struct IssuerListDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// The selected issuer.
    public let issuer: String
    
    /// Initializes the Issuer List details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The issuer list payment method.
    ///   - issuer: The selected issuer.
    public init(paymentMethod: IssuerListPaymentMethod, issuer: String) {
        self.type = paymentMethod.type
        self.issuer = issuer
    }
    
}

/// Contains the details supplied by the IDEAL component.
public typealias IdealDetails = IssuerListDetails

/// Contains the details supplied by the MOLPay component.
public typealias MOLPayDetails = IssuerListDetails

/// Contains the details supplied by the Dotpay component.
public typealias DotpayDetails = IssuerListDetails

/// Contains the details supplied by the EPS component.
public typealias EPSDetails = IssuerListDetails

/// Contains the details supplied by the Entercash component.
public typealias EntercashDetails = IssuerListDetails

/// Contains the details supplied by the OpenBanking component.
public typealias OpenBankingDetails = IssuerListDetails
