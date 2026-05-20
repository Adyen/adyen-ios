//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

/// A component that handles BCMC card payments.
package final class BCMCComponent: CardComponent {

    /// Initializes the BCMC Component.
    /// - Parameters:
    ///   - paymentMethod: BCMC payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The configuration of the component.
    package init(
        paymentMethod: BCMCPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration = .init()
    ) {
        let configuration = configuration.bcmcConfiguration()
        let binInfoProvider = BinInfoProvider(
            apiClient: APIClient(apiContext: context.apiContext),
            adyenContext: context,
            minBinLength: Constant.thresholdBINLength,
            binLookupType: configuration.binLookupType
        )
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            binProvider: binInfoProvider
        )
    }
    
    override internal init(
        paymentMethod: AnyCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration,
        binProvider: AnyBinInfoProvider
    ) {
        let configuration = configuration.bcmcConfiguration()
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            binProvider: binProvider
        )
    }

}

private extension CardConfiguration {
    
    func bcmcConfiguration() -> CardConfiguration {
        var configuration = CardConfiguration()
        configuration.style = style
        configuration.showCardholderName = showCardholderName
        configuration.showStorePaymentMethod = showStorePaymentMethod
        configuration.showSecurityCodeForStoredCard = showSecurityCodeForStoredCard
        configuration.showSupportedCardBrandLogos = false
        configuration.binLookupType = .bcmc
        configuration.localizationParameters = localizationParameters
        return configuration
    }
}
