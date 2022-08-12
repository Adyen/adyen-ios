//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation
import UIKit

/// A component that handles BCMC card payments.
public final class BCMCComponent: CardComponent {
    
    /// Initializes the BCMC Component.
    /// - Parameters:
    ///   - paymentMethod: BCMC payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The configuration of the component.
    public init(paymentMethod: BCMCPaymentMethod,
                context: AdyenContext,
                configuration: CardComponent.Configuration = .init()) {
        let configuration = configuration.bcmcConfiguration()
        
        let publicKeyProvider = PublicKeyProvider(apiContext: context.apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: context.apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.thresholdBINLength)
        super.init(paymentMethod: paymentMethod,
                   context: context,
                   configuration: configuration,
                   publicKeyProvider: publicKeyProvider,
                   binProvider: binInfoProvider)
    }
    
    override internal init(paymentMethod: AnyCardPaymentMethod,
                           context: AdyenContext,
                           configuration: Configuration,
                           publicKeyProvider: AnyPublicKeyProvider,
                           binProvider: AnyBinInfoProvider) {
        let configuration = configuration.bcmcConfiguration()
        super.init(paymentMethod: paymentMethod,
                   context: context,
                   configuration: configuration,
                   publicKeyProvider: publicKeyProvider,
                   binProvider: binProvider)
    }

}
