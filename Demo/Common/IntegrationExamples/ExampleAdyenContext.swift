//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import struct AdyenCheckout.CheckoutConfiguration
import AdyenNetworking

/// Creates the `AdyenContext` used by the component examples that construct components directly.
@MainActor
internal func makeExampleAdyenContext() async throws -> AdyenContext {
    let analyticsConfiguration = AnalyticsConfiguration(
        isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
    )

    let publicKey = try await PublicKeyFetcher().fetchPublicKey(
        apiClient: APIClient(apiContext: ConfigurationConstants.apiContext),
        clientKey: ConfigurationConstants.apiContext.clientKey
    )

    return AdyenContext(
        apiContext: ConfigurationConstants.apiContext,
        amount: ConfigurationConstants.current.amount,
        publicKey: publicKey,
        checkoutAttemptId: nil,
        analyticsAPIContext: CheckoutConfiguration.createAnalyticsAPIContext(apiContext: ConfigurationConstants.apiContext),
        analyticsConfiguration: analyticsConfiguration
    )
}
