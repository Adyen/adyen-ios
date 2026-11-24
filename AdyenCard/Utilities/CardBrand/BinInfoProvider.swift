//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

@MainActor
internal protocol AnyBinInfoProvider: AnyObject {
    func provide(for bin: String, supportedTypes: [CardBrand], completion: @escaping (BinLookupResponse) -> Void)
}

/// Provide cardBrand detection based on BinLookup API.
@MainActor
internal final class BinInfoProvider: AnyBinInfoProvider {

    private enum Constants {
        static let binLookupThrottlingDelay: TimeInterval = 0.5
    }
    
    private let minBinLength: Int

    private let apiClient: AsyncAPIClientProtocol

    private let adyenContext: AdyenContext

    private var binLookupService: AnyBinLookupService?

    private let fallbackCardBrandProvider: AnyBinInfoProvider
    
    private let binLookupType: BinLookupRequestType

    private let binLookupThrottler: Throttler

    private var currentPan = ""
    
    internal init(
        apiClient: AsyncAPIClientProtocol,
        adyenContext: AdyenContext,
        fallbackCardBrandProvider: AnyBinInfoProvider = FallbackBinInfoProvider(),
        minBinLength: Int,
        binLookupType: BinLookupRequestType,
        binLookupThrottler: Throttler = Throttler(minimumDelay: Constants.binLookupThrottlingDelay)
    ) {
        self.apiClient = apiClient
        self.adyenContext = adyenContext
        self.fallbackCardBrandProvider = fallbackCardBrandProvider
        self.minBinLength = minBinLength
        self.binLookupType = binLookupType
        self.binLookupThrottler = binLookupThrottler
    }
    
    /// Detects the card brands for the entered card number.
    ///
    /// If the number is shorter than `minBinLength`, the brands are detected locally and returned right away.
    /// Otherwise, the `/binlookup` request is sent after a short delay, and only for the latest number.
    /// Completions of earlier calls are not called.
    /// A `/binlookup` response is also ignored if the number has changed since the request.
    /// - Parameters:
    ///   - bin: The card number entered so far.
    ///   - supportedTypes: The supported card brands.
    ///   - completion: Called with the detected brands.
    internal func provide(for bin: String, supportedTypes: [CardBrand], completion: @escaping (BinLookupResponse) -> Void) {
        currentPan = bin
        let fallback: () -> Void = { [weak fallbackCardBrandProvider] in
            fallbackCardBrandProvider?.provide(
                for: bin,
                supportedTypes: supportedTypes,
                completion: completion
            )
        }

        let bin = String(bin.prefix(minBinLength))
        guard bin.count == minBinLength else {
            binLookupThrottler.cancel()
            return fallback()
        }

        binLookupThrottler.throttle { [weak self] in
            self?.requestBinLookup(for: bin, supportedTypes: supportedTypes, completion: completion, fallback: fallback)
        }
    }

    private func requestBinLookup(
        for bin: String,
        supportedTypes: [CardBrand],
        completion: @escaping (BinLookupResponse) -> Void,
        fallback: @escaping () -> Void
    ) {
        let useService: (AnyBinLookupService) -> Void = { [weak self] service in
            service.requestCardBrand(for: bin, supportedCardBrands: supportedTypes) { result in
                // A /binlookup response can arrive after the number has changed, so skip it if it's for an older number.
                guard let self, self.currentPan.hasPrefix(bin) else { return }
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
