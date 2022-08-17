//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable @_spi(AdyenInternal) import AdyenCard

final class PublicKeyProviderMock: AnyPublicKeyProvider {
    
    let apiContext: APIContext = Dummy.apiContext

    var onFetch: ((_ completion: @escaping Completion<Result<String, Error>>) -> Void)?

    func fetch(completion: @escaping Completion<Result<String, Error>>) {
        onFetch?(completion) ?? completion(.success(Dummy.publicKey))
    }
}
