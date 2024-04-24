//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2_Swift
import Foundation
@_spi(AdyenInternal) import Adyen

internal protocol AnyADYService {
    func transaction(withMessageVersion: String,
                     parameters: ServiceParameters,
                     appearanceConfiguration: ADYAppearanceConfiguration,
                     completionHandler: @escaping (Result<AnyADYTransaction, Error>) -> Void)
}

internal final class ADYServiceAdapter: AnyADYService {
    var transaction: Transaction?
    @MainActor func transaction(withMessageVersion: String,
                                parameters: Adyen3DS2_Swift.ServiceParameters,
                                appearanceConfiguration: ADYAppearanceConfiguration,
                                completionHandler: @escaping (Result<AnyADYTransaction, Error>) -> Void) {
        let appearance = appearanceConfiguration
        
        guard let messageVersion = MessageVersion(rawValue: withMessageVersion) else {
            fatalError("Unsupported message version")
        }
        
        Transaction.initialize(serviceParameters: parameters,
                               messageVersion: messageVersion,
                               securityDelegate: self,
                               appearanceConfiguration: appearance.appearanceConfiguration) { @MainActor result in
            switch result {
            case let .success(transaction):
                self.transaction = transaction
                completionHandler(.success(transaction))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
    
}

extension ADYServiceAdapter: SecurityWarningsDelegate {
    internal func securityWarningsFound(_ warnings: [Adyen3DS2_Swift.Warning]) {
        Swift.print("\(#function): warnings:\(warnings)")
    }
}
