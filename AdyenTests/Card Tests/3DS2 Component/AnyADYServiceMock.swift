//
//  AnyADYServiceMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
import Adyen3DS2
@testable import AdyenCard

final class AnyADYServiceMock: AnyADYService {

    func service(with parameters: ADYServiceParameters, appearanceConfiguration: ADYAppearanceConfiguration, completionHandler: @escaping (AnyADYService) -> Void) {
        completionHandler(self)
    }

    var authenticationRequestParameters: AnyAuthenticationRequestParameters?

    var mockedTransaction: AnyADYTransaction?

    func transaction(withMessageVersion: String) throws -> AnyADYTransaction {
        if let mockedTransaction = mockedTransaction {
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
