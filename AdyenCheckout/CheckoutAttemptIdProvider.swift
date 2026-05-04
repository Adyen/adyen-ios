//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol CheckoutAttemptIdProviding {
    func fetchCheckoutAttemptId(
        with apiClient: AsyncAPIClientProtocol?
    ) async -> String?
}

/// Default implementation that performs the actual API call to fetch the checkout attempt ID.
/// Note: If there is any failure in fetching the checkoutAttemptId then we will return nil,
/// as that would imply that there should not be any analytics events sent.
/// Improvement: This is an edge case and the current success rate of the api is pretty high 99 something so this would rarely ever fail.
/// If this ever becomes a constraint we could add a retying logic to try twice if it failed once. But that is an improvement if needed.
internal struct CheckoutAttemptIdProvider: CheckoutAttemptIdProviding {
    internal func fetchCheckoutAttemptId(
        with apiClient: AsyncAPIClientProtocol?
    ) async -> String? {
        guard let apiClient else {
            return nil
        }
        let request = CheckoutAttemptIdRequest()
        guard let response: CheckoutAttemptIdResponse = try? await apiClient.performAsync(request) else {
            return nil
        }
        return response.checkoutAttemptId
    }
}
