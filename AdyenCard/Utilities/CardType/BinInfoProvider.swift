//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyBinInfoProvider {
    /// :nodoc:
    func provideInfo(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void)
}

/// Provide cardType detection based on BinLookup API.
internal final class BinInfoProvider: AnyBinInfoProvider {
    
    private static let minBinLength = 11
    
    /// :nodoc:
    internal let apiClient: APIClientProtocol

    private var privateBinLookupService: BinLookupService?
    
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
                  fallbackCardTypeProvider: AnyBinInfoProvider = FallbackBinInfoProvider()) {
        self.apiClient = apiClient
        self.cardPublicKeyProvider = cardPublicKeyProvider
        self.fallbackCardTypeProvider = fallbackCardTypeProvider
    }
    
    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `minBinLength` - calls API, otherwise check local Regex.
    ///   - supportedTypes: Card brands supported by the merchant.
    ///   - completion:  Callback to notify about results.
    internal func provideInfo(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void) {
        guard bin.count >= BinInfoProvider.minBinLength else {
            return fallbackCardTypeProvider.provideInfo(for: bin,
                                                        supportedTypes: supportedTypes,
                                                        completion: completion)
        }
        
        fetchBinLookupService(
            success: { [weak self] service in
                self?.use(binLookupService: service,
                          for: bin,
                          supportedTypes: supportedTypes,
                          completion: completion)
            },
            failure: { [weak self] _ in
                self?.fallbackCardTypeProvider.provideInfo(for: bin, supportedTypes: supportedTypes, completion: completion)
            }
        )
    }

    private func use(binLookupService: BinLookupService,
                     for bin: String,
                     supportedTypes: [CardType],
                     completion: @escaping (BinLookupResponse) -> Void) {
        binLookupService.requestCardType(for: bin, supportedCardTypes: supportedTypes) { [weak self] result in
            switch result {
            case let .success(response):
                completion(response)
            case .failure:
                self?.fallbackCardTypeProvider.provideInfo(for: bin,
                                                           supportedTypes: supportedTypes,
                                                           completion: completion)
            }
        }
    }
    
    private func fetchBinLookupService(success: @escaping (BinLookupService) -> Void,
                                       failure: @escaping ((Swift.Error) -> Void)) {
        if let binLookupService = privateBinLookupService {
            return success(binLookupService)
        }

        let apiClient = apiClient
        cardPublicKeyProvider.fetch { [weak self] result in
            switch result {
            case let .success(publicKey):
                let binLookupService = BinLookupService(publicKey: publicKey,
                                                        apiClient: apiClient)
                self?.privateBinLookupService = binLookupService
                success(binLookupService)
            case let .failure(error):
                failure(error)
            }
        }
    }
}
