//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard

final class CardPublicKeyProviderMock: AnyCardPublicKeyProvider {
    
    let apiContext: APIContext = APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")

    var onFetch: ((_ completion: @escaping CompletionHandler) -> Void)?

    func fetch(completion: @escaping CompletionHandler) {
        onFetch?(completion)
    }
}
