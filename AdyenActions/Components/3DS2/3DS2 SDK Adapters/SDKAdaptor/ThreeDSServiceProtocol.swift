//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Foundation
@_spi(AdyenInternal) import Adyen

struct ChallengeParameters {
    let challengeToken: ThreeDS2Component.ChallengeToken
    let threeDSRequestorAppURL: URL
}

struct ServiceParameters {
    let directoryServerIdentifier: String
    let directoryServerPublicKey: String
    let directoryServerRootCertificates: String
    let deviceExcludedParameters: [String: Any]?
    let appearanceConfiguration: ADYAppearanceConfiguration
    let threeDSMessageVersion: String
}

internal enum ThreeDSServiceError: Error {
    case transactionNotInitialized
    case unknownError(UnknownError)
    case challengeError(Error)
}

internal protocol ThreeDSServiceProtocol {
    func authenticationParameters(parameters: ServiceParameters,
                                  completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, Error>) -> Void)
    func performChallenge(with parameters: ChallengeParameters,
                          completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceError>) -> Void)
}
