//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Foundation
@_spi(AdyenInternal) import Adyen

internal struct ChallengeParameters {
    internal let challengeToken: ThreeDS2Component.ChallengeToken
    internal let threeDSRequestorAppURL: URL?
}

internal struct ServiceParameters {
    internal let directoryServerIdentifier: String
    internal let directoryServerPublicKey: String
    internal let directoryServerRootCertificates: String
    internal let deviceExcludedParameters: [String: Any]?
    internal let appearanceConfiguration: Adyen3DS2.ADYAppearanceConfiguration
    internal let threeDSMessageVersion: String
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
    
    func isCancelled(error: Error) -> Bool
    func opaqueErrorObject(error: Error) -> String?
    
    func resetTransaction()
}
