//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
@_spi(AdyenInternal) @testable import AdyenActions
import Foundation

final class AnyADYServiceMock: AnyADYService {

    func service(with parameters: ADYServiceParameters, appearanceConfiguration: ADYAppearanceConfiguration, completionHandler: @escaping (AnyADYService) -> Void) {
        completionHandler(self)
    }

    var authenticationRequestParameters: AnyAuthenticationRequestParameters?

    var mockedTransaction: AnyADYTransaction?

    func transaction(withMessageVersion: String) throws -> AnyADYTransaction {
        if let mockedTransaction {
            return mockedTransaction
        } else if let parameters = authenticationRequestParameters {
            return AnyADYTransactionMock(parameters: parameters)
        } else {
            fatalError()
        }
    }
}

internal struct AuthenticationRequestParametersMock: AnyAuthenticationRequestParameters {

    var deviceInformation: String

    var sdkApplicationIdentifier: String

    var sdkTransactionIdentifier: String

    var sdkReferenceNumber: String

    var sdkEphemeralPublicKey: String

    var messageVersion: String
}

internal struct AnyChallengeResultMock: AnyChallengeResult {

    var sdkTransactionIdentifier: String

    var transactionStatus: String
}

final class AnyADYTransactionMock: AnyADYTransaction {

    let authenticationParameters: AnyAuthenticationRequestParameters

    init(parameters: AnyAuthenticationRequestParameters) {
        self.authenticationParameters = parameters
    }

    var onPerformChallenge: ((ADYChallengeParameters, (AnyChallengeResult?, Error?) -> Void) -> Void)?

    func performChallenge(with parameters: ADYChallengeParameters, completionHandler: @escaping (AnyChallengeResult?, Error?) -> Void) {
        onPerformChallenge?(parameters, completionHandler)
    }

}
