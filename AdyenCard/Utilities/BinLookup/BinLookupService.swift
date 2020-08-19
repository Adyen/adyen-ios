//
//  BinLookupService.swift
//  AdyenCard
//
//  Created by Vladimir Abramichev on 19/08/2020.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation

/// Provide cardType detection based on BinLookup API.
internal protocol AnyBinLookupService {
    func requestCardType(for bin: String, caller: @escaping (Result<BinLookupResponse, Error>) -> Void)
}

internal final class BinLookupService: AnyBinLookupService {

    private let supportedCardTypes: [CardType]
    private let publicKey: String
    private let apiClient: APIClientProtocol

    internal init(supportedCardTypes: [CardType], publicKey: String, apiClient: APIClientProtocol) {
        self.supportedCardTypes = supportedCardTypes
        self.publicKey = publicKey
        self.apiClient = apiClient
    }

    func requestCardType(for bin: String, caller: @escaping (Result<BinLookupResponse, Error>) -> Void) {
        let encryptedBin = try? CardEncryptor.encryptedCard(for: CardEncryptor.Card(number: bin),
                                                            publicKey: publicKey)
        let request = BinLookupRequest(encryptedBin: encryptedBin?.number ?? "",
                                       supportedBrands: supportedCardTypes)

        apiClient.perform(request, completionHandler: caller)
    }
}
