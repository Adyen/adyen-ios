//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol CardPublicKeyConsumer: PaymentComponent {
    var cardPublicKeyProvider: AnyCardPublicKeyProvider { get set }
}

extension CardPublicKeyConsumer {
    internal typealias CardKeySuccessHandler = (_ cardPublicKey: String) -> Void

    internal func fetchCardPublicKey(completion: @escaping CardKeySuccessHandler) {
        cardPublicKeyProvider.fetch { [weak self] in
            self?.handle(result: $0, completion: completion)
        }
    }

    private func handle(result: Result<String, Swift.Error>, completion: CardKeySuccessHandler) {
        switch result {
        case let .success(key):
            completion(key)
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        }
    }
}
