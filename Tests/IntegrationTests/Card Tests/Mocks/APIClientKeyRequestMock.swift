//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen

final class APIClientKeyRequestMock: APIClientKeyRequestProtocol {

    var mockedResults: [Result<ClientKeyResponse, Error>] = []
    var onPerform: (() -> Void)?

    private(set) var counter: Int = 0

    func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, Error>) -> Void) {
        counter += 1
        let nextResult = mockedResults.removeFirst()
        DispatchQueue.main.async {
            self.onPerform?()
            completionHandler(nextResult)
        }
    }
}
