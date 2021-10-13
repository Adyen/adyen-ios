//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyCardTypeProvider: Component {
    /// :nodoc:
    func requestCardTypes(for bin: String, supported cardType: [CardType], completion: @escaping ([CardType]) -> Void)
}

/// Provide cardType detection based on BinLookup API.
/// Fall back to local regex-based detector if API not available or BIN too short.
internal final class CardTypeProvider: AnyCardTypeProvider {
    private static let minBinLength = 6

    private let apiClient: APIClientProtocol?

    private var privateBinLookupService: BinLookupService?

    private let cardPublicKeyProvider: AnyCardPublicKeyProvider

    /// Create a new instance of CardTypeProvider.
    /// - Parameters:
    ///   - supportedCardTypes: Array of supported cads.
    ///   - apiClient: Any instance of `APIClientProtocol`.
    ///   - cardPublicKeyProvider: Any instance of `AnyCardPublicKeyProvider`.
    internal init(cardPublicKeyProvider: AnyCardPublicKeyProvider, apiClient: APIClientProtocol? = nil) {
        self.apiClient = apiClient
        self.cardPublicKeyProvider = cardPublicKeyProvider
    }

    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `minBinLength` - calls API, otherwise check local Regex,
    ///   - completion:  Callback to notify about results.
    internal func requestCardTypes(for bin: String, supported cardType: [CardType], completion: @escaping ([CardType]) -> Void) {
        guard bin.count > CardTypeProvider.minBinLength else {
            return completion(cardType.adyen.types(forCardNumber: bin))
        }

        fetchBinLookupService(success: { binLookupService in
            binLookupService.requestCardType(for: bin,
                                             supportedCardTypes: cardType) { result in
                switch result {
                case let .success(response):
                    completion(response.detectedBrands ?? [])
                case .failure:
                    completion(cardType.adyen.types(forCardNumber: bin))
                }
            }
        }, failure: { _ in
            completion(cardType.adyen.types(forCardNumber: bin))
        })
    }

    private func fetchBinLookupService(success: @escaping (BinLookupService) -> Void,
                                       failure: ((Swift.Error) -> Void)? = nil)
    {
        if let binLookupService = privateBinLookupService {
            return success(binLookupService)
        }

        let localApiClient = apiClient ?? APIClient(environment: environment)

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
