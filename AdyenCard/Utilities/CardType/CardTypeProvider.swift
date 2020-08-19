//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provide cardType detection based on BinLookup API.
/// Fall back to local regex-based detector if API not available or BIN too short.
internal final class CardTypeProvider: Component {
    
    private static let MinBinLength = 7
    
    private let cardTypeDetector: CardTypeDetector
    private let apiClient: APIClientProtocol?
    private let privateSupportedCardTypes: [CardType]
    private var privateBinLookupService: BinLookupService?
    private let cardPublicKeyProvider: AnyCardPublicKeyProvider
    
    /// Set of excluded card types.
    internal var excludedCardTypes: Set<CardType> = []
    
    private var supportedCardTypes: [CardType] {
        privateSupportedCardTypes.filter { !excludedCardTypes.contains($0) }
    }
    
    /// Create a new instance of CardTypeProvider.
    /// - Parameters:
    ///   - supportedCardTypes: Array of supported cads.
    ///   - apiClient: Any instance of `APIClientProtocol`.
    ///   - cardPublicKeyProvider: Any instance of `AnyCardPublicKeyProvider`.
    internal init(supportedCardTypes: [CardType], cardPublicKeyProvider: AnyCardPublicKeyProvider, apiClient: APIClientProtocol? = nil) {
        cardTypeDetector = CardTypeDetector(detectableTypes: supportedCardTypes)
        self.apiClient = apiClient
        self.privateSupportedCardTypes = supportedCardTypes
        self.cardPublicKeyProvider = cardPublicKeyProvider
    }
    
    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `MinBinLength` - calls API, otherwise check local Regex,
    ///   - caller:  Callback to notify about results.
    internal func requestCardType(for bin: String, caller: @escaping ([CardType]) -> Void) {
        guard bin.count >= CardTypeProvider.MinBinLength else {
            return caller(cardTypeDetector.types(forCardNumber: bin))
        }
        
        try? fetchbinLookupService(success: { binLookupService in
            binLookupService.requestCardType(for: bin) { result in
                switch result {
                case let .success(response):
                    caller(response.detectedBrands)
                case .failure:
                    caller(self.cardTypeDetector.types(forCardNumber: bin))
                }
            }
        }, failure: { _ in
            caller(self.cardTypeDetector.types(forCardNumber: bin))
        })
    }
    
    private func fetchbinLookupService(success: @escaping (BinLookupService) -> Void,
                                       failure: ((Swift.Error) -> Void)? = nil) throws {
        if let binLookupService = privateBinLookupService { return success(binLookupService) }
        
        try cardPublicKeyProvider.fetch { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(publicKey):
                let binLookupService = BinLookupService(supportedCardTypes: self.supportedCardTypes,
                                                        publicKey: publicKey,
                                                        apiClient: self.apiClient ?? APIClient(environment: self.environment))
                self.privateBinLookupService = binLookupService
                success(binLookupService)
            case let .failure(error):
                failure?(error)
            }
        }
    }
}
