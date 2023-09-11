//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol PublicKeyConsumer: PaymentComponent {

    /// Provider for fetching the public key.
    var publicKeyProvider: AnyPublicKeyProvider { get }
}

/// :nodoc:
extension PublicKeyConsumer {
    /// :nodoc:
    public typealias PublicKeySuccessHandler = (_ publicKey: String) -> Void

    /// :nodoc:
    /// Convenient way to fetch the client public key with a closure for the success case
    /// and an option to notify the delegate on the failure case.
    /// - Parameters:
    ///   - notifyingDelegateOnFailure: If `true`, notifies the `PaymentComponentDelegate` on failure.
    ///   - successHandler: The block that is called when fetching was successful. Contains the public key.
    public func fetchCardPublicKey(notifyingDelegateOnFailure: Bool, successHandler: PublicKeySuccessHandler? = nil) {
        publicKeyProvider.fetch { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(key):
                successHandler?(key)
            case let .failure(error):
                if notifyingDelegateOnFailure {
                    self.delegate?.didFail(with: error, from: self)
                }
            }
        }
    }
}
