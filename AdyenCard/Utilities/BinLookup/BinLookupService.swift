//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
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
        let encryptedBin: String
        do {
            encryptedBin = try CardEncryptor.encrypt(bin: bin, with: publicKey)
        } catch {
            return caller(.failure(error))
        }
        
        let request = BinLookupRequest(encryptedBin: encryptedBin, supportedBrands: supportedCardTypes)
        apiClient.perform(request, completionHandler: caller)
    }
}
