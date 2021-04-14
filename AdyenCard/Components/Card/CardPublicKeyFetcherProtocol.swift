//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol CardPublicKeyFetcherProtocol: PaymentComponent {
    var cardPublicKeyProvider: AnyCardPublicKeyProvider { get set }
}

extension CardPublicKeyFetcherProtocol {
    internal typealias CardKeySuccessHandler = (_ cardPublicKey: String) -> Void
    internal typealias CardKeyFailureHandler = (_ error: Swift.Error) -> Void

    internal func fetchCardPublicKey(onError: CardKeyFailureHandler? = nil, completion: @escaping CardKeySuccessHandler) {
        do {
            try cardPublicKeyProvider.fetch { [weak self] in
                self?.handle(result: $0, onError: onError, completion: completion)
            }
        } catch {
            if let onError = onError {
                onError(error)
            } else {
                delegate?.didFail(with: error, from: self)
            }
        }
    }

    private func handle(result: Result<String, Swift.Error>, onError: CardKeyFailureHandler? = nil, completion: CardKeySuccessHandler) {
        switch result {
        case let .success(key):
            completion(key)
        case let .failure(error):
            if let onError = onError {
                onError(error)
            } else {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
}
