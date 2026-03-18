//
// Copyright (c) 2020 Adyen N.V.
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
    
    typealias CompletionHandler = (Result<BinLookupResponse, Error>) -> Void
    
    func requestCardType(for bin: String, supportedCardTypes: [CardType], completion: @escaping CompletionHandler)
}

internal final class BinLookupService: AnyBinLookupService {
    
    private let publicKey: String
    
    private let apiClient: AsyncAPIClientProtocol

    private var cache = [String: BinLookupResponse]()
    
    private let binLookupType: BinLookupRequestType
    
    internal init(publicKey: String, apiClient: AsyncAPIClientProtocol, binLookupType: BinLookupRequestType) {
        self.publicKey = publicKey
        self.apiClient = apiClient
        self.binLookupType = binLookupType
    }
    
    internal func requestCardType(
        for bin: String,
        supportedCardTypes: [CardType],
        completion: @escaping CompletionHandler
    ) {
        if let cached = cache[bin] {
            return completion(.success(cached))
        }

        let encryptedBin: String
        do {
            encryptedBin = try CardEncryptor.encrypt(bin: bin, with: publicKey)
        } catch {
            return completion(.failure(error))
        }
        
        let request = BinLookupRequest(encryptedBin: encryptedBin, supportedBrands: supportedCardTypes, type: binLookupType)
        Task { @MainActor in
            do {
                let response: BinLookupResponse = try await apiClient.performAsync(request)
                cache[bin] = response
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
