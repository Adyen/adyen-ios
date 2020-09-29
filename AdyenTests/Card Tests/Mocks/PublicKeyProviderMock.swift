//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard

final class CardPublicKeyProviderMock: AnyCardPublicKeyProvider {

    var onFetch: ((_ completion: @escaping CompletionHandler) -> Void)?

    func fetch(completion: @escaping CompletionHandler) throws {
        onFetch?(completion)
    }
}
