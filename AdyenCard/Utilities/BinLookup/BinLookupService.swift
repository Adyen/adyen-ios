//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import AdyenNetworking
import Foundation

/// Provide cardType detection based on BinLookup API.
internal protocol AnyBinLookupService {

    func requestCardType(for bin: String, supportedCardTypes: [CardType],
                         caller: @escaping Completion<Result<BinLookupResponse, Error>>)
}

internal final class BinLookupService: AnyBinLookupService {
    
    private let publicKey: String
    
    private let apiClient: APIClientProtocol

    private var cache = [String: BinLookupResponse]()
    
    internal init(publicKey: String, apiClient: APIClientProtocol) {
        self.publicKey = publicKey
        self.apiClient = apiClient
    }
    
    internal func requestCardType(for bin: String, supportedCardTypes: [CardType],
                                  caller: @escaping Completion<Result<BinLookupResponse, Error>>) {
        if let cached = cache[bin] {
            return caller(.success(cached))
        }

        let encryptedBin: String
        do {
            encryptedBin = try CardEncryptor.encrypt(bin: bin, with: publicKey)
        } catch {
            return caller(.failure(error))
        }
        
        let request = BinLookupRequest(encryptedBin: encryptedBin, supportedBrands: supportedCardTypes)
        apiClient.perform(request) { [weak self] result in
            _ = result.map { self?.cache[bin] = $0 }
            caller(result)
        }
    }
}
