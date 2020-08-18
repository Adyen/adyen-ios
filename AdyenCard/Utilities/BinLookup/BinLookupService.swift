//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provide cardType detection based on BinLookup API.
internal protocol AnyBinLookupService {
    func requestCardType(for bin: String, caller: @escaping (BinLookupResponse) -> Void)
}

/// Provide cardType detection based on BinLookup API.
/// Fall back to local regex-based detector if API not available or BIN too short.
internal final class BinLookupService: AnyBinLookupService {
    
    private static let MinBinLength = 7
    
    private lazy var cardTypeDetector: CardTypeDetector = CardTypeDetector(detectableTypes: self.supportedCardTypes)
    private let supportedCardTypes: [CardType]
    private let publicKey: String
    private let clientKey: String
    private let apiClient: APIClientProtocol
    
    internal init(supportedCardTypes: [CardType], environment: APIEnvironment, publicKey: String, clientKey: String) {
        self.supportedCardTypes = supportedCardTypes
        self.publicKey = publicKey
        self.clientKey = clientKey
        self.apiClient = APIClient(environment: environment)
    }
    
    /// Request card types based on enterd BIN.
    /// - Parameters:
    ///   - bin: Card's BIN number. If longer than `MinBinLength` - calls API, otherwise check local Regex,
    ///   - caller:  Callback to notify about results.
    internal func requestCardType(for bin: String, caller: @escaping (BinLookupResponse) -> Void) {
        if bin.count < BinLookupService.MinBinLength {
            caller(BinLookupResponse(brands: cardTypeDetector.types(forCardNumber: bin)))
        } else {
            let encryptedBin = try? CardEncryptor.encryptedCard(for: CardEncryptor.Card(number: bin),
                                                                publicKey: publicKey)
            let request = BinLookupRequest(clientKey: clientKey,
                                           encryptedBin: encryptedBin?.number ?? "",
                                           supportedBrands: supportedCardTypes)
            
            apiClient.perform(request) { result in
                switch result {
                case let .success(response):
                    caller(response)
                case let .failure(error):
                    adyenPrint("---- BinLookup (/\(error)) ----")
                    caller(BinLookupResponse(brands: self.cardTypeDetector.types(forCardNumber: bin)))
                }
            }
        }
    }
    
}
