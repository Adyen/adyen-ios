//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provide cardType detection based on BinLookup API.
/// Fall back to local regex-based detector if API not available or BIN too short.
internal final class CardTypeProvider {
    
    private static let MinBinLength = 7
    
    private let cardTypeDetector: CardTypeDetector
    private let binLookupService: AnyBinLookupService
    
    internal init(supportedCardTypes: [CardType], environment: APIEnvironment, publicKey: String) {
        cardTypeDetector = CardTypeDetector(detectableTypes: supportedCardTypes)
        binLookupService = BinLookupService(supportedCardTypes: supportedCardTypes,
                                            publicKey: publicKey,
                                            apiClient: APIClient(environment: environment))
    }
    
    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `MinBinLength` - calls API, otherwise check local Regex,
    ///   - caller:  Callback to notify about results.
    internal func requestCardType(for bin: String, caller: @escaping ([CardType]) -> Void) {
        if bin.count < CardTypeProvider.MinBinLength {
            caller(cardTypeDetector.types(forCardNumber: bin))
        } else {
            binLookupService.requestCardType(for: bin) { result in
                switch result {
                case let .success(response):
                    caller(response.detectedBrands)
                case .failure:
                    caller(self.cardTypeDetector.types(forCardNumber: bin))
                }
            }
        }
    }
    
}
