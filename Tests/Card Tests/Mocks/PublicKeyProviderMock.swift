//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_documentation(visibility: internal) @testable import AdyenCard

final class PublicKeyProviderMock: AnyPublicKeyProvider {
    
    let apiContext: APIContext = Dummy.apiContext

    var onFetch: ((_ completion: @escaping CompletionHandler) -> Void)?

    func fetch(completion: @escaping CompletionHandler) {
        onFetch?(completion) ?? completion(.success(Dummy.publicKey))
    }
}
