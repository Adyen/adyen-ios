//
//  PublicKeyProviderMock.swift
//  AdyenTests
//
//  Created by Vladimir Abramichev on 24/08/2020.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard

final class CardPublicKeyProviderMock: AnyCardPublicKeyProvider {

    var onFetch: ((_ completion: @escaping CompletionHandler) -> Void)?

    func fetch(completion: @escaping CompletionHandler) throws {
        onFetch?(completion)
    }
}
