//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provide cardType detection based on BinLookup API.
internal protocol AnyBinLookupService {
    
    /// :nodoc:
    typealias CompletionHandler = (Result<BinLookupResponse, Error>) -> Void
    
    /// :nodoc:
    func requestCardType(for bin: String, supportedCardTypes: [CardType], caller: @escaping CompletionHandler)
}

internal final class BinLookupService: AnyBinLookupService {
    
    private let publicKey: String
    
    private let apiClient: APIClientProtocol
    
    internal init(publicKey: String, apiClient: APIClientProtocol) {
        self.publicKey = publicKey
        self.apiClient = apiClient
    }
    
    internal func requestCardType(for bin: String, supportedCardTypes: [CardType], caller: @escaping CompletionHandler) {
        let encryptedBin = try? CardEncryptor.encryptedCard(for: CardEncryptor.Card(number: bin),
                                                            publicKey: publicKey)
        let request = BinLookupRequest(encryptedBin: encryptedBin?.number ?? "",
                                       supportedBrands: supportedCardTypes)
        
        apiClient.perform(request, completionHandler: caller)
    }
}
