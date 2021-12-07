//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
internal protocol AnyBinInfoProvider: AnyObject {
    /// :nodoc:
    func provide(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void)
}

/// Provide cardType detection based on BinLookup API.
internal final class BinInfoProvider: AnyBinInfoProvider {
    
    private let minBinLength: Int

    private let apiClient: APIClientProtocol

    private var binLookupService: BinLookupService?
    
    private let cardPublicKeyProvider: AnyCardPublicKeyProvider

    private let fallbackCardTypeProvider: AnyBinInfoProvider
    
    /// Create a new instance of CardTypeProvider.
    /// - Parameters:
    ///   - apiContext: The API context,
    ///   - cardPublicKeyProvider: Any instance of `AnyCardPublicKeyProvider`.
    ///   - fallbackCardTypeProvider: Any instance of `AnyCardBrandProvider` to be used as a fallback
    ///   if API not available or BIN too short.
    internal init(apiClient: APIClientProtocol,
                  cardPublicKeyProvider: AnyCardPublicKeyProvider,
                  fallbackCardTypeProvider: AnyBinInfoProvider = FallbackBinInfoProvider(),
                  minBinLength: Int) {
        self.apiClient = apiClient
        self.cardPublicKeyProvider = cardPublicKeyProvider
        self.fallbackCardTypeProvider = fallbackCardTypeProvider
        self.minBinLength = minBinLength
    }
    
    /// Request card types based on entered BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `minBinLength` - calls API, otherwise check local Regex.
    ///   - supportedTypes: Card brands supported by the merchant.
    ///   - completion:  Callback to notify about results.
    internal func provide(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void) {
        let fallback: () -> Void = { [weak fallbackCardTypeProvider] in
            fallbackCardTypeProvider?.provide(for: bin,
                                              supportedTypes: supportedTypes,
                                              completion: completion)
        }

        let bin = String(bin.prefix(minBinLength))
        guard bin.count == minBinLength else {
            return fallback()
        }

        let useService: (BinLookupService) -> Void = { service in
            service.requestCardType(for: bin, supportedCardTypes: supportedTypes) { result in
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
            cardPublicKeyProvider.fetch { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(publicKey):
                    let service = BinLookupService(publicKey: publicKey, apiClient: self.apiClient)
                    self.binLookupService = service
                    useService(service)
                case .failure:
                    fallback()
                }
            }
        }
    }

}
