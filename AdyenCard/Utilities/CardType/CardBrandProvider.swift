//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyCardBrandProvider: Component {
    /// :nodoc:
    func provide(for parameters: CardBrandProviderParameters, completion: @escaping (BinLookupResponse) -> Void)
}

/// Describes input parameters to an instance of `AnyCardBrandProvider`.
internal struct CardBrandProviderParameters {

    /// Indicates the card BIN.
    internal let bin: String

    /// Indicates the card types supported by the merchant.
    internal let supportedTypes: [CardType]
}

/// Provide cardType detection based on BinLookup API.
internal final class CardBrandProvider: AnyCardBrandProvider {
    
    private static let minBinLength = 11
    
    private let apiClient: APIClientProtocol?

    private var privateBinLookupService: BinLookupService?
    
    private let cardPublicKeyProvider: AnyCardPublicKeyProvider

    private let fallbackCardTypeProvider: AnyCardBrandProvider
    
    /// Create a new instance of CardTypeProvider.
    /// - Parameters:
    ///   - supportedCardTypes: Array of supported cads.
    ///   - apiClient: Any instance of `APIClientProtocol`.
    ///   - cardPublicKeyProvider: Any instance of `AnyCardPublicKeyProvider`.
    ///   - fallbackCardTypeProvider: Any instance of `AnyCardBrandProvider` to be used as a fallback
    ///   if API not available or BIN too short.
    internal init(cardPublicKeyProvider: AnyCardPublicKeyProvider,
                  apiClient: APIClientProtocol? = nil,
                  fallbackCardTypeProvider: AnyCardBrandProvider = FallbackCardBrandProvider()) {
        self.apiClient = apiClient
        self.cardPublicKeyProvider = cardPublicKeyProvider
        self.fallbackCardTypeProvider = fallbackCardTypeProvider
    }
    
    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `minBinLength` - calls API, otherwise check local Regex.
    ///   - brands: Card brands supported by the merchant.
    ///   - completion:  Callback to notify about results.
    internal func provide(for parameters: CardBrandProviderParameters, completion: @escaping (BinLookupResponse) -> Void) {
        guard parameters.bin.count >= CardBrandProvider.minBinLength else {
            return fallbackCardTypeProvider.provide(for: parameters,
                                                    completion: completion)
        }
        
        fetchBinLookupService(
            success: { [weak self] service in
                self?.use(binLookupService: service,
                          parameters: parameters,
                          completion: completion)
            },
            failure: { [weak self] _ in
                self?.fallbackCardTypeProvider.provide(for: parameters, completion: completion)
            }
        )
    }

    private func use(binLookupService: BinLookupService,
                     parameters: CardBrandProviderParameters,
                     completion: @escaping (BinLookupResponse) -> Void) {
        binLookupService.requestCardType(for: parameters.bin,
                                         supportedCardTypes: parameters.supportedTypes) { [weak self] result in
            self?.handle(result: result,
                         parameters: parameters,
                         completion: completion)
        }
    }

    private func handle(result: Result<BinLookupResponse, Error>,
                        parameters: CardBrandProviderParameters,
                        completion: @escaping (BinLookupResponse) -> Void) {
        switch result {
        case let .success(response):
            completion(response)
        case .failure:
            fallbackCardTypeProvider.provide(for: parameters,
                                             completion: completion)
        }
    }
    
    private func fetchBinLookupService(success: @escaping (BinLookupService) -> Void,
                                       failure: ((Swift.Error) -> Void)? = nil) {
        if let binLookupService = privateBinLookupService {
            return success(binLookupService)
        }
        
        let localApiClient = self.apiClient ?? APIClient(environment: self.environment)
        
        do {
            try cardPublicKeyProvider.fetch { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case let .success(publicKey):
                    let binLookupService = BinLookupService(publicKey: publicKey,
                                                            apiClient: localApiClient)
                    self.privateBinLookupService = binLookupService
                    success(binLookupService)
                case let .failure(error):
                    failure?(error)
                }
            }
        } catch {
            failure?(error)
        }
    }
}
