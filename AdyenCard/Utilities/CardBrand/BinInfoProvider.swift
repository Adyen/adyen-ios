//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol AnyBinInfoProvider: AnyObject {
    func provide(for bin: String, supportedTypes: [CardBrand], completion: @escaping (BinLookupResponse) -> Void)
}

/// Provide cardBrand detection based on BinLookup API.
internal final class BinInfoProvider: AnyBinInfoProvider {
    
    private let minBinLength: Int

    private let apiClient: AsyncAPIClientProtocol

    private let adyenContext: AdyenContext

    private var binLookupService: AnyBinLookupService?

    private let fallbackCardBrandProvider: AnyBinInfoProvider
    
    private let binLookupType: BinLookupRequestType
    
    internal init(
        apiClient: AsyncAPIClientProtocol,
        adyenContext: AdyenContext,
        fallbackCardBrandProvider: AnyBinInfoProvider = FallbackBinInfoProvider(),
        minBinLength: Int,
        binLookupType: BinLookupRequestType
    ) {
        self.apiClient = apiClient
        self.adyenContext = adyenContext
        self.fallbackCardBrandProvider = fallbackCardBrandProvider
        self.minBinLength = minBinLength
        self.binLookupType = binLookupType
    }
    
    /// Request card types based on entered BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `minBinLength` - calls API, otherwise check local Regex.
    ///   - supportedTypes: Card brands supported by the merchant.
    ///   - completion:  Callback to notify about results.
    internal func provide(for bin: String, supportedTypes: [CardBrand], completion: @escaping (BinLookupResponse) -> Void) {
        let fallback: () -> Void = { [weak fallbackCardBrandProvider] in
            fallbackCardBrandProvider?.provide(
                for: bin,
                supportedTypes: supportedTypes,
                completion: completion
            )
        }

        let bin = String(bin.prefix(minBinLength))
        guard bin.count == minBinLength else {
            return fallback()
        }

        let useService: (AnyBinLookupService) -> Void = { service in
            service.requestCardBrand(for: bin, supportedCardBrands: supportedTypes) { result in
                switch result {
                case let .success(response):
                    completion(response)
                case .failure:
                    fallback()
                }
            }
        }
        
        if let service = binLookupService {
            useService(service)
        } else {
            let service = BinLookupService(publicKey: adyenContext.publicKey, apiClient: self.apiClient, binLookupType: self.binLookupType)
            self.binLookupService = service
            useService(service)
        }
    }

}
