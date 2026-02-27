//
// Copyright (c) 2019 Adyen N.V.
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
    public init(
        paymentMethod: BCMCPaymentMethod,
        context: AdyenContext,
        publicKey: String,
        configuration: CardComponentConfiguration = .init()
    ) {
        let configuration = configuration.bcmcConfiguration()
        
        let binInfoProvider = BinInfoProvider(
            apiClient: APIClient(apiContext: context.apiContext),
            publicKey: publicKey,
            minBinLength: Constant.thresholdBINLength,
            binLookupType: configuration.binLookupType
        )
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKey: publicKey,
            binProvider: binInfoProvider
        )
    }
    
    override internal init(
        paymentMethod: AnyCardPaymentMethod,
        context: AdyenContext,
        configuration: CardComponentConfiguration,
        publicKey: String,
        binProvider: AnyBinInfoProvider
    ) {
        let configuration = configuration.bcmcConfiguration()
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKey: publicKey,
            binProvider: binProvider
        )
    }

}

private extension CardComponentConfiguration {
    
    func bcmcConfiguration() -> CardComponentConfiguration {
        var configuration = CardComponentConfiguration()
        configuration.style = style
        configuration.showsHolderNameField = showsHolderNameField
        configuration.showsStorePaymentMethodField = showsStorePaymentMethodField
        configuration.stored = stored
        configuration.showsSupportedCardLogos = false
        configuration.binLookupType = .bcmc
        configuration.localizationParameters = localizationParameters
        return configuration
    }
}
